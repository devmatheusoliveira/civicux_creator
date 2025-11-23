-- Tabela para armazenar configurações da aplicação
CREATE TABLE IF NOT EXISTS app_config (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  config_key TEXT UNIQUE NOT NULL,
  config_value TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Índice para busca rápida por chave
CREATE INDEX IF NOT EXISTS idx_app_config_key ON app_config(config_key);

-- Habilitar RLS (Row Level Security)
ALTER TABLE app_config ENABLE ROW LEVEL SECURITY;

-- Política para permitir leitura apenas com autenticação
CREATE POLICY "Permitir leitura autenticada" ON app_config
  FOR SELECT
  USING (true);

-- Política para permitir inserção/atualização apenas com autenticação
CREATE POLICY "Permitir escrita autenticada" ON app_config
  FOR ALL
  USING (true)
  WITH CHECK (true);

-- Inserir a chave do Gemini (substitua YOUR_GEMINI_API_KEY pela sua chave real)
INSERT INTO app_config (config_key, config_value, description)
VALUES (
  'gemini_api_key',
  'YOUR_GEMINI_API_KEY',
  'Chave de API do Google Gemini'
)
ON CONFLICT (config_key) 
DO UPDATE SET 
  config_value = EXCLUDED.config_value,
  updated_at = TIMEZONE('utc'::text, NOW());

-- Função para atualizar o timestamp automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = TIMEZONE('utc'::text, NOW());
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger para atualizar updated_at automaticamente
DROP TRIGGER IF EXISTS update_app_config_updated_at ON app_config;
CREATE TRIGGER update_app_config_updated_at
  BEFORE UPDATE ON app_config
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
