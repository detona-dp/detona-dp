-- ============================================================
-- DETONA — Schema de base de datos
-- Supabase PostgreSQL
-- ============================================================

-- Autores
CREATE TABLE IF NOT EXISTS autores (
  id              BIGSERIAL PRIMARY KEY,
  nombre          TEXT NOT NULL,
  nombre_norm     TEXT GENERATED ALWAYS AS (lower(trim(nombre))) STORED,
  fecha_muerte    INTEGER,           -- año de fallecimiento
  nacionalidad    TEXT DEFAULT 'MX',
  notas           TEXT,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Obras
CREATE TABLE IF NOT EXISTS obras (
  id                  BIGSERIAL PRIMARY KEY,
  titulo              TEXT NOT NULL,
  titulo_norm         TEXT GENERATED ALWAYS AS (lower(trim(titulo))) STORED,
  tipo                TEXT,          -- musical, literaria, dramatica, artistica
  anio_registro       INTEGER,       -- año de registro en DOF
  anio_publicacion    INTEGER,       -- año de primera publicación
  num_registro        TEXT,          -- número de registro en DOF
  clase               TEXT,          -- clase según DOF (A, B, etc.)
  monto_derechos      NUMERIC(10,2), -- monto pagado según DOF
  fuente_dof          TEXT,          -- referencia al PDF/DOF de origen
  pagina_dof          INTEGER,
  -- Motor jurídico
  ley_aplicable       TEXT,          -- 'CC1884', 'CC1928', 'LFDA1948', 'LFDA1956', 'LFDA1996', 'LFDA2003'
  anio_vencimiento    INTEGER,       -- año calculado de vencimiento de protección
  es_dominio_publico  BOOLEAN,
  nivel_certeza       TEXT CHECK (nivel_certeza IN ('alto', 'medio', 'bajo')),
  fundamento_legal    TEXT,          -- artículos que sustentan la determinación
  notas_juridicas     TEXT,
  -- Metadata
  created_at          TIMESTAMPTZ DEFAULT NOW(),
  updated_at          TIMESTAMPTZ DEFAULT NOW()
);

-- Relación obras-autores (muchos a muchos)
CREATE TABLE IF NOT EXISTS obras_autores (
  obra_id     BIGINT REFERENCES obras(id) ON DELETE CASCADE,
  autor_id    BIGINT REFERENCES autores(id) ON DELETE CASCADE,
  rol         TEXT DEFAULT 'autor',  -- autor, compositor, letrista, adaptador
  PRIMARY KEY (obra_id, autor_id)
);

-- Índices para búsqueda
CREATE INDEX IF NOT EXISTS idx_obras_titulo_norm    ON obras(titulo_norm);
CREATE INDEX IF NOT EXISTS idx_obras_anio_registro  ON obras(anio_registro);
CREATE INDEX IF NOT EXISTS idx_obras_dominio        ON obras(es_dominio_publico);
CREATE INDEX IF NOT EXISTS idx_obras_ley            ON obras(ley_aplicable);
CREATE INDEX IF NOT EXISTS idx_autores_nombre_norm  ON autores(nombre_norm);

-- Búsqueda de texto completo
CREATE INDEX IF NOT EXISTS idx_obras_fts ON obras
  USING GIN (to_tsvector('spanish', titulo));

CREATE INDEX IF NOT EXISTS idx_autores_fts ON autores
  USING GIN (to_tsvector('spanish', nombre));

-- Vista principal para el buscador
CREATE OR REPLACE VIEW obras_completas AS
SELECT
  o.id,
  o.titulo,
  o.tipo,
  o.anio_registro,
  o.anio_publicacion,
  o.num_registro,
  o.clase,
  o.fuente_dof,
  o.ley_aplicable,
  o.anio_vencimiento,
  o.es_dominio_publico,
  o.nivel_certeza,
  o.fundamento_legal,
  o.notas_juridicas,
  -- Autores como array
  COALESCE(
    array_agg(a.nombre ORDER BY a.nombre) FILTER (WHERE a.nombre IS NOT NULL),
    ARRAY[]::TEXT[]
  ) AS autores,
  -- Autores como texto para búsqueda
  COALESCE(
    string_agg(a.nombre, ', ' ORDER BY a.nombre) FILTER (WHERE a.nombre IS NOT NULL),
    ''
  ) AS autores_texto
FROM obras o
LEFT JOIN obras_autores oa ON oa.obra_id = o.id
LEFT JOIN autores a        ON a.id = oa.autor_id
GROUP BY o.id;

-- RLS: lectura pública, escritura solo autenticada
ALTER TABLE obras   ENABLE ROW LEVEL SECURITY;
ALTER TABLE autores ENABLE ROW LEVEL SECURITY;
ALTER TABLE obras_autores ENABLE ROW LEVEL SECURITY;

CREATE POLICY "lectura publica obras"
  ON obras FOR SELECT USING (true);

CREATE POLICY "lectura publica autores"
  ON autores FOR SELECT USING (true);

CREATE POLICY "lectura publica obras_autores"
  ON obras_autores FOR SELECT USING (true);

-- Vista también pública
GRANT SELECT ON obras_completas TO anon;
GRANT SELECT ON obras TO anon;
GRANT SELECT ON autores TO anon;
GRANT SELECT ON obras_autores TO anon;
