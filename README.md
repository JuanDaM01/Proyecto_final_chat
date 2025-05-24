# 📡 Chat Distribuido en Elixir

Sistema de mensajería en tiempo real desarrollado con Elixir y Phoenix, que ofrece una interfaz gráfica amigable para gestionar salas de chat, autenticación por nombre de usuario y contraseñas opcionales.

---

## 📁 Estructura del Proyecto


chat_distribuido_elixir/
├── chat_server/     # Servidor Phoenix
└── chat_client/     # Cliente con interfaz gráfica


---

## ⚙ Requisitos

- Elixir >= *1.14*
- Erlang/OTP >= *25*
- Phoenix Framework

---

## 🚀 Instalación y Ejecución

1. Clona el repositorio o descarga el proyecto:
   bash
   git clone https://github.com/JuanDaM01/Proyecto_final_chat.git
   

2. Instala las dependencias:
   bash
   cd chat_server && mix deps.get
   cd ../chat_client && mix deps.get
   

3. Inicia el servidor:
   bash
   cd ../chat_server
   mix phx.server
   

4. Abre el navegador y entra a [http://localhost:4000](http://localhost:4000)

---

## 🖼 Interfaz de Usuario

- El sistema presenta una interfaz gráfica en la que se pueden:
  - Ver salas de chat disponibles.
  - Crear nuevas salas con o sin contraseña.
  - Eliminar salas (si tienes permisos).
  - Ingresar con nombre de usuario a una sala seleccionada.

---

## ✨ Funcionalidades

- 🔓 Autenticación por nombre de usuario.
- 🔐 Protección opcional de salas mediante contraseña.
- 💬 Chat en tiempo real en cada sala.
- ➕ Creación dinámica de salas.
- ❌ Eliminación de salas por usuarios autorizados.
- 🎨 Interfaz visual moderna y responsive.

---

## 🌐 Detalles Técnicos

- El servidor maneja la persistencia de las salas y usuarios en tiempo real usando Phoenix Channels.
- La interfaz gráfica está integrada al servidor Phoenix, construida en HTML, CSS (Tailwind o similar), y JS para eventos en vivo.
- No requiere comandos en consola para usar funcionalidades: todo es visual e intuitivo.

---

## 🧪 Pruebas

Puedes agregar pruebas usando ExUnit:
bash
mix test


---

## 📦 Despliegue

1. Configura el entorno de producción.
2. Crea un release:
   bash
   MIX_ENV=prod mix release
   
3. Usa Docker, VPS o plataformas como Fly.io o Render para desplegar.

---

## 📚 Recursos

- [Documentación Phoenix](https://hexdocs.pm/phoenix/)
- [Elixir Lang](https://elixir-lang.org/)
