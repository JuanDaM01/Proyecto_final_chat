# Despliegue de Phoenix en Producción

## 1. Compila tu app para producción

```sh
MIX_ENV=prod mix deps.get --only prod
MIX_ENV=prod mix compile
```

## 2. Prepara los assets (si usas Tailwind, JS, etc.)

```sh
MIX_ENV=prod mix assets.deploy
```

## 3. Genera el release

```sh
MIX_ENV=prod mix release
```

## 4. Configura variables de entorno

- `PORT` (por ejemplo, 4000 o 80)
- `SECRET_KEY_BASE` (usa `mix phx.gen.secret` para generar uno)

## 5. Inicia el release

```sh
_build/prod/rel/chat_app/bin/chat_app start
```

## 6. Abre el puerto en el firewall y/o router

- Permite el puerto en el firewall del servidor.
- Si es acceso desde Internet, haz port forwarding en el router.

## 7. Accede desde cualquier PC

- Usa la IP pública o de red del servidor:  
  `http://IP_DEL_SERVIDOR:PUERTO`

## 8. (Opcional) Configura HTTPS

- Usa un proxy inverso como Nginx o Caddy para HTTPS.
- O configura directamente en Phoenix con certificados.

---
