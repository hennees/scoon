-- ============================================================
-- scoon – Supabase Database Schema
-- Run this in the Supabase SQL Editor (Dashboard → SQL Editor)
-- ============================================================

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
-- PostGIS for geo-queries (enabled by default on Supabase)
-- CREATE EXTENSION IF NOT EXISTS "postgis";

-- ============================================================
-- TABLES
-- ============================================================

-- Profiles (extends Supabase auth.users 1:1)
CREATE TABLE public.profiles (
    id               UUID        REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    username         TEXT        NOT NULL UNIQUE,
    bio              TEXT        NOT NULL DEFAULT '',
    avatar_url       TEXT        NOT NULL DEFAULT '',
    post_count       INT         NOT NULL DEFAULT 0,
    follower_count   INT         NOT NULL DEFAULT 0,
    following_count  INT         NOT NULL DEFAULT 0,
    is_premium       BOOLEAN     NOT NULL DEFAULT FALSE,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Spots
CREATE TABLE public.spots (
    id           UUID             DEFAULT uuid_generate_v4() PRIMARY KEY,
    creator_id   UUID             REFERENCES public.profiles(id) ON DELETE CASCADE,
    name         TEXT             NOT NULL,
    location     TEXT             NOT NULL,
    description  TEXT             NOT NULL DEFAULT '',
    category     TEXT             NOT NULL,
    latitude     DOUBLE PRECISION,
    longitude    DOUBLE PRECISION,
    image_url    TEXT             NOT NULL DEFAULT '',
    rating       DOUBLE PRECISION NOT NULL DEFAULT 0,
    view_count   INT              NOT NULL DEFAULT 0,
    like_count   INT              NOT NULL DEFAULT 0,
    save_count   INT              NOT NULL DEFAULT 0,
    is_verified  BOOLEAN          NOT NULL DEFAULT FALSE,
    created_at   TIMESTAMPTZ      NOT NULL DEFAULT NOW()
);

-- Favorites (user ↔ spot many-to-many)
CREATE TABLE public.favorites (
    user_id    UUID        REFERENCES public.profiles(id) ON DELETE CASCADE,
    spot_id    UUID        REFERENCES public.spots(id)    ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, spot_id)
);

-- Transactions (creator earnings)
CREATE TABLE public.transactions (
    id          UUID             DEFAULT uuid_generate_v4() PRIMARY KEY,
    creator_id  UUID             REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    spot_id     UUID             REFERENCES public.spots(id)    ON DELETE SET NULL,
    amount      NUMERIC(10, 2)   NOT NULL,
    currency    TEXT             NOT NULL DEFAULT 'EUR',
    status      TEXT             NOT NULL DEFAULT 'pending', -- paid | pending | failed
    created_at  TIMESTAMPTZ      NOT NULL DEFAULT NOW()
);

-- ============================================================
-- VIEW: spots enriched with is_favorite for the current user
-- ============================================================
CREATE OR REPLACE VIEW public.spots_with_favorites AS
SELECT
    s.*,
    EXISTS(
        SELECT 1 FROM public.favorites f
        WHERE f.spot_id = s.id AND f.user_id = auth.uid()
    ) AS is_favorite
FROM public.spots s;

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE public.profiles     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.spots        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.favorites    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

-- Profiles
CREATE POLICY "profiles_select_all"  ON public.profiles FOR SELECT USING (true);
CREATE POLICY "profiles_insert_own"  ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "profiles_update_own"  ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Spots: public read, authenticated users can create
CREATE POLICY "spots_select_all"     ON public.spots FOR SELECT USING (true);
CREATE POLICY "spots_insert_auth"    ON public.spots FOR INSERT WITH CHECK (auth.uid() = creator_id);
CREATE POLICY "spots_update_own"     ON public.spots FOR UPDATE USING (auth.uid() = creator_id);
CREATE POLICY "spots_delete_own"     ON public.spots FOR DELETE USING (auth.uid() = creator_id);

-- Favorites: users see and manage their own
CREATE POLICY "favorites_select_own" ON public.favorites FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "favorites_insert_own" ON public.favorites FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "favorites_delete_own" ON public.favorites FOR DELETE USING (auth.uid() = user_id);

-- Transactions: creators see their own earnings
CREATE POLICY "transactions_select_own" ON public.transactions FOR SELECT USING (auth.uid() = creator_id);

-- ============================================================
-- TRIGGER: auto-create profile when a user signs up
-- ============================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
    INSERT INTO public.profiles (id, username, avatar_url)
    VALUES (
        NEW.id,
        COALESCE(
            NEW.raw_user_meta_data->>'username',
            split_part(NEW.email, '@', 1)
        ),
        COALESCE(NEW.raw_user_meta_data->>'avatar_url', '')
    );
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- ============================================================
-- INDEXES for performance
-- ============================================================
CREATE INDEX spots_category_idx   ON public.spots (category);
CREATE INDEX spots_rating_idx     ON public.spots (rating DESC);
CREATE INDEX spots_creator_idx    ON public.spots (creator_id);
CREATE INDEX favorites_user_idx   ON public.favorites (user_id);
CREATE INDEX transactions_creator ON public.transactions (creator_id);

-- ============================================================
-- RPC: Nearby spots with distance ordering
-- ============================================================
CREATE OR REPLACE FUNCTION public.get_nearby_spots(
    user_lat DOUBLE PRECISION,
    user_lon DOUBLE PRECISION,
    radius_meters DOUBLE PRECISION DEFAULT 2500
)
RETURNS TABLE (
    id UUID,
    name TEXT,
    location TEXT,
    rating DOUBLE PRECISION,
    image_url TEXT,
    is_favorite BOOLEAN,
    description TEXT,
    view_count INT,
    like_count INT,
    save_count INT,
    distance TEXT,
    category TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION
)
LANGUAGE sql
STABLE
SECURITY INVOKER
AS $$
    SELECT
        s.id,
        s.name,
        s.location,
        s.rating,
        s.image_url,
        EXISTS (
            SELECT 1
            FROM public.favorites f
            WHERE f.spot_id = s.id AND f.user_id = auth.uid()
        ) AS is_favorite,
        s.description,
        s.view_count,
        s.like_count,
        s.save_count,
        CONCAT(
            ROUND(
                (
                    (
                        6371000 * ACOS(
                            LEAST(
                                1,
                                COS(RADIANS(user_lat)) * COS(RADIANS(s.latitude)) *
                                COS(RADIANS(s.longitude) - RADIANS(user_lon)) +
                                SIN(RADIANS(user_lat)) * SIN(RADIANS(s.latitude))
                            )
                        )
                    ) / 1000.0
                )::numeric,
                1
            ),
            ' km'
        ) AS distance,
        s.category,
        s.latitude,
        s.longitude
    FROM public.spots s
    WHERE s.latitude IS NOT NULL
      AND s.longitude IS NOT NULL
      AND (
        6371000 * ACOS(
            LEAST(
                1,
                COS(RADIANS(user_lat)) * COS(RADIANS(s.latitude)) *
                COS(RADIANS(s.longitude) - RADIANS(user_lon)) +
                SIN(RADIANS(user_lat)) * SIN(RADIANS(s.latitude))
            )
        )
      ) <= radius_meters
    ORDER BY
        6371000 * ACOS(
            LEAST(
                1,
                COS(RADIANS(user_lat)) * COS(RADIANS(s.latitude)) *
                COS(RADIANS(s.longitude) - RADIANS(user_lon)) +
                SIN(RADIANS(user_lat)) * SIN(RADIANS(s.latitude))
            )
        ) ASC;
$$;

GRANT EXECUTE ON FUNCTION public.get_nearby_spots(DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION) TO authenticated;