#!/bin/bash

# 1. Cria o arquivo .env com as variáveis do painel da Vercel
echo "GEMINI_API_KEY=$GEMINI_API_KEY" > .env
echo "SUPABASE_URL=$SUPABASE_URL" >> .env
echo "SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY" >> .env

# 2. Instala o Flutter se não existir
if [ ! -d flutter ]; then 
  git clone https://github.com/flutter/flutter.git
fi

# 3. Configura e baixa dependências
./flutter/bin/flutter build web --release
flutter config --enable-web
flutter pub get