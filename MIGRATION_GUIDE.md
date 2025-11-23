# 🔐 Migração da Chave do Gemini para Supabase

## ✅ O que foi feito

### 1. Problema Resolvido
- ❌ **Antes**: A chave do Gemini estava no arquivo `.env`, que vazou ao fazer deploy na Vercel
- ✅ **Agora**: A chave é armazenada de forma segura no Supabase

### 2. Arquivos Criados

#### `supabase_setup.sql`
Script SQL para criar a tabela `app_config` no Supabase com:
- Estrutura da tabela
- Políticas de segurança (RLS)
- Triggers para atualização automática de timestamps

#### `lib/services/config_service.dart`
Serviço para gerenciar configurações do Supabase com:
- Cache de 30 minutos para performance
- Métodos para buscar/atualizar a chave do Gemini
- Métodos genéricos para outras configurações

#### `lib/pages/settings/settings_page.dart`
Página de configurações com interface para:
- Visualizar a chave (mascarada)
- Atualizar a chave do Gemini
- Instruções de como obter a chave

### 3. Arquivos Modificados

#### `lib/services/gemini_service.dart`
- ❌ Removido: `import 'package:flutter_dotenv/flutter_dotenv.dart';`
- ✅ Adicionado: `import 'config_service.dart';`
- ✅ Agora busca a chave do Supabase via `ConfigService`

#### `lib/services/nano_banana_service.dart`
- ❌ Removido: `import 'package:flutter_dotenv/flutter_dotenv.dart';`
- ✅ Adicionado: `import 'config_service.dart';`
- ✅ Agora busca a chave do Supabase via `ConfigService`

#### `lib/app.dart`
- ✅ Adicionado rotas nomeadas (`/settings`, `/setup`)
- ✅ Importado `SettingsPage`

#### `lib/pages/home/home_page.dart`
- ✅ Adicionado botão de configurações no AppBar

## 📋 Próximos Passos (IMPORTANTE!)

### Passo 1: Configurar o Supabase

1. Acesse o dashboard do Supabase: https://app.supabase.com
2. Selecione seu projeto
3. Vá em **SQL Editor**
4. Abra o arquivo `supabase_setup.sql`
5. **IMPORTANTE**: Substitua `YOUR_GEMINI_API_KEY` pela sua chave real do Gemini
6. Copie e cole o conteúdo no SQL Editor
7. Clique em **Run**

### Passo 2: Verificar a Configuração

1. Vá em **Table Editor** no Supabase
2. Procure pela tabela `app_config`
3. Confirme que existe uma linha com:
   - `config_key`: `gemini_api_key`
   - `config_value`: Sua chave do Gemini

### Passo 3: Testar a Aplicação

```bash
flutter run -d chrome
```

1. Faça login na aplicação
2. Clique no ícone de configurações (⚙️) no AppBar
3. Verifique se a chave aparece (mascarada)
4. Tente gerar conteúdo ou imagens para confirmar que está funcionando

### Passo 4: Configurar Políticas de Segurança (Produção)

⚠️ **IMPORTANTE**: As políticas atuais permitem acesso público. Para produção:

1. Vá em **Authentication** > **Policies** no Supabase
2. Edite as políticas da tabela `app_config`
3. Restrinja o acesso apenas para usuários autenticados

Exemplo:
```sql
-- Leitura apenas para autenticados
CREATE POLICY "Permitir leitura autenticada" ON app_config
  FOR SELECT
  USING (auth.role() = 'authenticated');

-- Escrita apenas para admins
CREATE POLICY "Permitir escrita admin" ON app_config
  FOR ALL
  USING (auth.jwt() ->> 'role' = 'admin')
  WITH CHECK (auth.jwt() ->> 'role' = 'admin');
```

## 🔒 Segurança

### O que NÃO fazer:
- ❌ Não commite a chave do Gemini no Git
- ❌ Não deixe a chave no `.env` (pode remover após migração)
- ❌ Não use políticas públicas em produção

### O que fazer:
- ✅ Mantenha `.env` no `.gitignore`
- ✅ Use variáveis de ambiente da Vercel apenas para `SUPABASE_URL` e `SUPABASE_ANON_KEY`
- ✅ Configure políticas de segurança adequadas no Supabase
- ✅ Use a página de configurações para atualizar a chave quando necessário

## 🚀 Deploy na Vercel

### Variáveis de Ambiente Necessárias:

Apenas estas variáveis precisam estar na Vercel:
- `SUPABASE_URL`: URL do seu projeto Supabase
- `SUPABASE_ANON_KEY`: Chave anônima do Supabase

A chave do Gemini **NÃO** deve estar nas variáveis de ambiente da Vercel!

## 📚 Documentação Adicional

- `SUPABASE_CONFIG.md`: Guia detalhado de configuração
- `supabase_setup.sql`: Script SQL para criar a tabela

## 🆘 Troubleshooting

### Erro: "GEMINI_API_KEY não configurada"
- Verifique se executou o script SQL no Supabase
- Confirme que a chave está na tabela `app_config`
- Verifique as políticas de segurança (RLS)

### Erro ao buscar configuração
- Verifique a conexão com o Supabase
- Confirme que `SUPABASE_URL` e `SUPABASE_ANON_KEY` estão corretos
- Verifique as políticas de segurança

### Cache não atualiza
- O cache expira após 30 minutos
- Para forçar atualização, reinicie o app
- Ou use `ConfigService().clearCache()`

## 📞 Suporte

Se tiver problemas:
1. Verifique os logs do console
2. Confirme a configuração do Supabase
3. Teste a conexão com o Supabase
4. Verifique as políticas de segurança
