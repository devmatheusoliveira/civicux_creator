# Configuração da Chave do Gemini no Supabase

## 🔐 Segurança Aprimorada

A chave da API do Gemini agora é armazenada de forma segura no Supabase, evitando vazamento em deploys na Vercel ou outras plataformas.

## 📋 Passos para Configuração

### 1. Criar a Tabela no Supabase

1. Acesse o dashboard do Supabase: https://app.supabase.com
2. Selecione seu projeto
3. Vá em **SQL Editor** (no menu lateral)
4. Copie e cole o conteúdo do arquivo `supabase_setup.sql`
5. **IMPORTANTE**: Antes de executar, substitua `YOUR_GEMINI_API_KEY` pela sua chave real do Gemini
6. Clique em **Run** para executar o script

### 2. Verificar a Configuração

Após executar o script, você pode verificar se a tabela foi criada corretamente:

1. Vá em **Table Editor** no Supabase
2. Procure pela tabela `app_config`
3. Você deve ver uma linha com:
   - `config_key`: `gemini_api_key`
   - `config_value`: Sua chave do Gemini
   - `description`: Chave de API do Google Gemini

### 3. Configurar as Políticas de Segurança (RLS)

O script já configura automaticamente as políticas de segurança (Row Level Security). 

**⚠️ IMPORTANTE**: As políticas atuais permitem leitura e escrita para todos. Para produção, você deve:

1. Ir em **Authentication** > **Policies** no Supabase
2. Editar as políticas da tabela `app_config`
3. Restringir o acesso apenas para usuários autenticados ou roles específicos

Exemplo de política mais segura:
```sql
-- Permitir leitura apenas para usuários autenticados
CREATE POLICY "Permitir leitura autenticada" ON app_config
  FOR SELECT
  USING (auth.role() = 'authenticated');

-- Permitir escrita apenas para administradores
CREATE POLICY "Permitir escrita admin" ON app_config
  FOR ALL
  USING (auth.jwt() ->> 'role' = 'admin')
  WITH CHECK (auth.jwt() ->> 'role' = 'admin');
```

### 4. Atualizar a Chave (Opcional)

Se você precisar atualizar a chave do Gemini posteriormente:

**Opção A - Via SQL Editor:**
```sql
UPDATE app_config 
SET config_value = 'SUA_NOVA_CHAVE_AQUI'
WHERE config_key = 'gemini_api_key';
```

**Opção B - Via Table Editor:**
1. Vá em **Table Editor**
2. Selecione a tabela `app_config`
3. Edite a linha com `config_key = 'gemini_api_key'`
4. Atualize o campo `config_value`

**Opção C - Via App (Futuro):**
Você pode criar uma página de configurações no app para atualizar a chave usando o `ConfigService`.

## 🚀 Como Funciona

### No Código

O sistema agora usa o `ConfigService` para buscar a chave do Gemini:

```dart
// Busca a chave do Supabase
final apiKey = await ConfigService().getGeminiApiKey();
```

### Cache

Para melhorar a performance, a chave é armazenada em cache por 30 minutos. Isso reduz o número de requisições ao Supabase.

### Serviços Atualizados

Os seguintes serviços foram atualizados para usar o Supabase:
- ✅ `GeminiService` - Geração de conteúdo de texto
- ✅ `NanoBananaService` - Geração de imagens

## 🔄 Migração do .env

Se você estava usando `.env` anteriormente:

1. Copie sua chave do arquivo `.env`
2. Adicione-a no Supabase usando os passos acima
3. O arquivo `.env` ainda é necessário para `SUPABASE_URL` e `SUPABASE_ANON_KEY`
4. Você pode remover `GEMINI_API_KEY` do `.env` após confirmar que está funcionando

## ⚠️ Importante

- **Nunca** commite a chave do Gemini no Git
- Mantenha o `.env` no `.gitignore`
- Configure as políticas de segurança do Supabase adequadamente
- Use variáveis de ambiente da Vercel apenas para `SUPABASE_URL` e `SUPABASE_ANON_KEY`

## 🧪 Testando

Após configurar, teste a aplicação:

1. Execute o app: `flutter run -d chrome`
2. Tente gerar conteúdo ou imagens
3. Verifique se não há erros relacionados à chave da API

Se houver problemas, verifique:
- A chave está corretamente configurada no Supabase
- As políticas de segurança permitem leitura
- A conexão com o Supabase está funcionando
