-- ============================================================
-- scoon – Demo Seed Data (Graz & Umgebung)
-- Ausführen in: Supabase Dashboard → SQL Editor
-- ============================================================
-- Hinweis: creator_id ist NULL → Spots sichtbar für alle,
-- kein echter User nötig.  RLS wird im SQL-Editor umgangen.
-- ============================================================

INSERT INTO public.spots
    (name, location, description, category, latitude, longitude, image_url, rating, view_count, like_count, save_count, is_verified)
VALUES

-- ── Graz Innenstadt ─────────────────────────────────────────

(
    'Schlossberg Panorama',
    'Schlossberg, Graz',
    'Der Schlossberg ist das Wahrzeichen von Graz. Von der Plattform hast du einen 360°-Blick über die gesamte Grazer Altstadt und die steirischen Berge. Besonders am Abend wenn die Stadt leuchtet ist dieser Spot unschlagbar.',
    'Nature',
    47.0739, 15.4394,
    'https://images.unsplash.com/photo-1577083288073-40892c0860a4?auto=format&fit=crop&w=800&q=80',
    4.9, 3842, 512, 287,
    TRUE
),

(
    'Kunsthaus Graz',
    'Lendkai, Graz',
    'Das "Friendly Alien" – so nennen die Grazer ihr futuristisches Kunsthaus am Murufer. Die geschwungene Fassade aus Acrylglasblasen ist ein einzigartiges Fotomotiv, besonders bei Gegenlicht oder bei Nacht wenn es leuchtet.',
    'Architecture',
    47.0703, 15.4383,
    'https://images.unsplash.com/photo-1549490349-8643362247b5?auto=format&fit=crop&w=800&q=80',
    4.7, 2916, 388, 201,
    TRUE
),

(
    'Murinsel',
    'Mur, Graz',
    'Eine schwimmende Stahlinsel mitten in der Mur, entworfen vom New Yorker Künstler Vito Acconci. Das Café und die Bühne sind von einer überdachten Schale umgeben – von beiden Murufer-Brücken fotografisch spektakulär.',
    'Architecture',
    47.0712, 15.4356,
    'https://images.unsplash.com/photo-1565793939-0bd85a5ef89c?auto=format&fit=crop&w=800&q=80',
    4.5, 2104, 295, 178,
    TRUE
),

(
    'Uhrturm Goldene Stunde',
    'Schlossberg, Graz',
    'Der Uhrturm auf dem Schlossberg ist eines der bekanntesten Symbole von Graz. In der goldenen Stunde vor Sonnenuntergang leuchtet der Turm warm orange – der perfekte Moment für ein Foto von der Terrasse darunter.',
    'Monuments',
    47.0741, 15.4393,
    'https://images.unsplash.com/photo-1528360983277-13d401cdc186?auto=format&fit=crop&w=800&q=80',
    4.8, 3201, 441, 256,
    TRUE
),

(
    'Hauptplatz Graz',
    'Hauptplatz, Graz',
    'Das Herzstück der Altstadt. Das Erzherzog-Johann-Denkmal in der Mitte, umgeben von bunten Barockfassaden. Frühmorgens vor dem Rummel hat man den Platz fast für sich – das blaue Stundenlicht taucht alles in eine magische Atmosphäre.',
    'Urban',
    47.0705, 15.4383,
    'https://images.unsplash.com/photo-1568515387631-8b650bbcdb90?auto=format&fit=crop&w=800&q=80',
    4.4, 1876, 243, 134,
    TRUE
),

(
    'Stadtpark Rosenbeete',
    'Stadtpark, Graz',
    'Der älteste Stadtpark Österreichs hat im Frühjahr und Sommer wunderschöne Rosenbeete. Der Stadtparkbrunnen und die alten Bäume bieten traumhafte Motive, besonders wenn Sonnenstrahlen durch das Blätterdach fallen.',
    'Park & Garten',
    47.0740, 15.4520,
    'https://images.unsplash.com/photo-1585320806297-9794b3e4eeae?auto=format&fit=crop&w=800&q=80',
    4.3, 1543, 198, 112,
    FALSE
),

(
    'Grazer Dom Portal',
    'Burggasse, Graz',
    'Das Südportal des Grazer Doms mit seinen spätgotischen Reliefs ist handwerkliche Meisterarbeit. Die Details der Steinmetzarbeit kommen bei flachem Seitenlicht am Morgen besonders schön zur Geltung.',
    'Architecture',
    47.0705, 15.4412,
    'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?auto=format&fit=crop&w=800&q=80',
    4.2, 987, 132, 89,
    FALSE
),

(
    'Landhaus Arkadenhof',
    'Herrengasse, Graz',
    'Der Renaissance-Arkadenhof des Grazer Landhauses gilt als einer der schönsten Höfe Österreichs. Drei Stockwerke geschwungener Arkaden aus dem 16. Jahrhundert – ein Hidden Gem mitten in der Innenstadt.',
    'Architecture',
    47.0706, 15.4384,
    'https://images.unsplash.com/photo-1592595896616-c37162298647?auto=format&fit=crop&w=800&q=80',
    4.6, 1654, 221, 158,
    TRUE
),

-- ── Graz Außenbezirke ────────────────────────────────────────

(
    'Schloss Eggenberg Spiegelgarten',
    'Eggenberger Allee, Graz',
    'Der Barockgarten von Schloss Eggenberg mit seinem großen Spiegelteich ist ein UNESCO-Weltkulturerbe. Früh am Morgen spiegelt sich das Schloss perfekt im stillen Wasser – diese Ruhe ist selten zu finden.',
    'Architecture',
    47.0682, 15.3905,
    'https://images.unsplash.com/photo-1589308078059-be1415eab4c3?auto=format&fit=crop&w=800&q=80',
    4.8, 2788, 389, 234,
    TRUE
),

(
    'Hilmteich Sonnenaufgang',
    'Hilmteich, Graz',
    'Der Hilmteich im Leechwald ist ein verstecktes Naturjuwel. Bei Nebel im Herbst und Winter hängen Schwaden über dem Wasser, während die Sonne dahinter aufgeht – absolutes Naturschauspiel.',
    'Nature',
    47.0811, 15.4644,
    'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=800&q=80',
    4.7, 1923, 278, 187,
    TRUE
),

(
    'Leechwald Nebelstimmung',
    'Leechwald, Graz',
    'Der Leechwald östlich der Stadt bietet an Herbstmorgen surreale Nebellandschaften. Zwischen den alten Laubbäumen bilden sich mystische Lichtkegel – am besten eine Stunde nach Sonnenaufgang.',
    'Nature',
    47.0849, 15.4628,
    'https://images.unsplash.com/photo-1448375240586-882707db888b?auto=format&fit=crop&w=800&q=80',
    4.5, 1432, 192, 143,
    FALSE
),

(
    'Kalvarienberg Aussicht',
    'Kalvarienberg, Graz',
    'Der Kalvarienberg im Westen bietet über die Dächer von Graz hinweg einen ungewöhnlichen Blick auf den Schlossberg. Besonders reizvoll wenn Morgennebel in den Tälern liegt und der Schlossberg herausragt.',
    'Nature',
    47.0748, 15.4251,
    'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=800&q=80',
    4.4, 1105, 149, 98,
    FALSE
),

(
    'Basilika Mariatrost',
    'Mariatrost, Graz',
    'Die Wallfahrtsbasilika thront auf einem Hügel über dem Raababachtal. Die lange Freitreppe mit 294 Stufen führt direkt zum Hauptportal – von oben hat man einen weiten Blick ins steirische Hügelland.',
    'Monuments',
    47.0990, 15.5083,
    'https://images.unsplash.com/photo-1548183585-cc35d4e2a5bd?auto=format&fit=crop&w=800&q=80',
    4.6, 1789, 241, 167,
    TRUE
),

(
    'Plabutsch Waldbad',
    'Plabutsch, Graz',
    'Der Wald am Plabutsch westlich der Stadt ist für Langzeitbelichtungen wie gemacht. Moosbewachsene Felsen, ein kleiner Bach und alte Fichten schaffen eine fast märchenhafte Stimmung.',
    'Nature',
    47.0848, 15.3799,
    'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?auto=format&fit=crop&w=800&q=80',
    4.3, 876, 118, 79,
    FALSE
),

-- ── Lend & Umgebung ──────────────────────────────────────────

(
    'Lend Grafitti Wall',
    'Grieskai, Graz',
    'Entlang des Grieskai im Lend-Viertel erstreckt sich eine der längsten Street-Art-Wände der Stadt. Die Werke wechseln regelmäßig – jeder Besuch zeigt neue Kunst. Tageslicht von Süden beleuchtet die Wand optimal.',
    'Urban',
    47.0720, 15.4250,
    'https://images.unsplash.com/photo-1499781350541-7783f6c6a0c8?auto=format&fit=crop&w=800&q=80',
    4.1, 1234, 176, 95,
    FALSE
),

(
    'Augarten Graz',
    'Augarten, Graz',
    'Der Augarten nördlich des Zentrums ist Grazer Lieblingsort für Spaziergänge. Im Frühling leuchten Kirschblüten entlang der Alleen – ein japanischer Frühlingstraum mitten in der Steiermark.',
    'Park & Garten',
    47.0795, 15.4467,
    'https://images.unsplash.com/photo-1462275646964-a0e3386b89fa?auto=format&fit=crop&w=800&q=80',
    4.2, 1098, 154, 88,
    FALSE
),

(
    'Forum Stadtpark Nacht',
    'Forum Stadtpark, Graz',
    'Das Forum Stadtpark mit seinen Neon-Lettern ist nachts ein surreales Motiv. Der ruhige Stadtpark dahinter im blauen Stundenlicht und die farbigen Reflexionen im nassen Kopfsteinpflaster machen diesen Spot besonders.',
    'Urban',
    47.0739, 15.4524,
    'https://images.unsplash.com/photo-1519681393784-d120267933ba?auto=format&fit=crop&w=800&q=80',
    4.0, 892, 121, 67,
    FALSE
),

-- ── Umland Graz ─────────────────────────────────────────────

(
    'Schöckel Gipfelblick',
    'Schöckel, Steiermark',
    'Der Hausberg der Grazer. Vom Gipfel des Schöckls (1445m) siehst du an klaren Tagen von den Alpen bis weit in die steirische Hügellandschaft. Sonnenaufgangs-Wanderungen im Sommer sind legendär.',
    'Nature',
    47.2023, 15.4729,
    'https://images.unsplash.com/photo-1506905589346-a9e59d7b36e5?auto=format&fit=crop&w=800&q=80',
    4.9, 4123, 567, 312,
    TRUE
),

(
    'Stubenbergsee Spiegel',
    'Stubenbergsee, Steiermark',
    'Dieser kleine See östlich von Graz liegt eingebettet in Wälder und Weinberge. An windstillen Morgen spiegeln sich die umgebenden Bäume perfekt im glatten Wasser – ideal für symmetrische Kompositionen.',
    'Nature',
    47.2308, 15.7164,
    'https://images.unsplash.com/photo-1501854140801-50d01698950b?auto=format&fit=crop&w=800&q=80',
    4.6, 1876, 254, 178,
    TRUE
),

(
    'Riegersburg Felswand',
    'Riegersburg, Steiermark',
    'Die Burg Riegersburg thront auf einem 482 Meter hohen Vulkanfelsen. Die senkrechte Basaltwand ist aus der Ebene davor besonders dramatisch – Teleobjektiv empfohlen. Abends leuchtet die Burg im Flutlicht.',
    'Architecture',
    46.9960, 15.9373,
    'https://images.unsplash.com/photo-1585320806297-9794b3e4eeae?auto=format&fit=crop&w=800&q=80',
    4.7, 2341, 312, 203,
    TRUE
);

-- ── Kurze Überprüfung ────────────────────────────────────────
SELECT COUNT(*) AS anzahl_spots, ROUND(AVG(rating)::numeric, 2) AS durchschnitt_rating FROM public.spots;
