import Foundation

/// Supabase PostgREST + Auth API endpoint paths.
/// Base URL is the Supabase Project URL (e.g. https://xyz.supabase.co)
enum APIEndpoints {

    enum Auth {
        /// POST – email/password login. Add ?grant_type=password as query item.
        static let signIn        = "/auth/v1/token"
        /// POST – email/password registration
        static let signUp        = "/auth/v1/signup"
        /// POST – sign out (requires Bearer token)
        static let signOut       = "/auth/v1/logout"
        /// GET  – current authenticated user
        static let currentUser   = "/auth/v1/user"
        /// GET  – initiate OAuth provider flow (add ?provider=google&redirect_to=...)
        static let authorize     = "/auth/v1/authorize"
        /// POST – refresh access token. Add ?grant_type=refresh_token as query item.
        static let refreshToken  = "/auth/v1/token"
    }

    enum Spots {
        /// View with is_favorite computed per authenticated user
        static let list      = "/rest/v1/spots_with_favorites"
        /// POST to add a new spot (use /rest/v1/spots – not the view)
        static let create    = "/rest/v1/spots"
        /// POST RPC for distance-based nearby search
        static let nearbyRPC = "/rest/v1/rpc/get_nearby_spots"
    }

    enum Favorites {
        static let list   = "/rest/v1/favorites"
        static let create = "/rest/v1/favorites"
        /// DELETE with query ?spot_id=eq.{id}&user_id=eq.{uid}
        static let delete = "/rest/v1/favorites"
    }

    enum Users {
        /// GET ?id=eq.{uid}&select=*
        static let me = "/rest/v1/profiles"
    }

    enum Creator {
        /// GET ?creator_id=eq.{uid}&order=created_at.desc
        static let transactions = "/rest/v1/transactions"
    }
}
