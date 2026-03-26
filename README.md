# 🎬 MovieMatch

Una aplicación móvil Flutter para descubrir, buscar y guardar películas favoritas, con autenticación de usuarios y recomendaciones personalizadas.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=flat&logo=dart)
![Supabase](https://img.shields.io/badge/Supabase-2.x-3ECF8E?style=flat&logo=supabase)
![TMDB](https://img.shields.io/badge/TMDB_API-v3-01B4E4?style=flat)
![Android](https://img.shields.io/badge/Android-API_21+-3DDC84?style=flat&logo=android)

---

## 📱 Capturas de pantalla

> *(Agregar capturas del dispositivo aquí)*

---

## ✨ Funcionalidades

| Pantalla | Descripción |
|---|---|
| **Login / Registro** | Autenticación con email y contraseña vía Supabase. Sesión persistente. |
| **Home** | Secciones: *Para ti*, *Populares* (scroll horizontal) y *En tendencia* (grid). |
| **Sorpréndeme 🎲** | Botón flotante que navega a una película aleatoria de TMDB. |
| **Búsqueda** | TextField con debounce de 500ms. Resultados con poster + título + año + rating. |
| **Detalle** | Poster a pantalla completa, géneros, sinopsis, rating TMDB, calificación personal con estrellas (0.5–5.0). |
| **Favoritos ❤️** | Lista sincronizada con Supabase. Swipe derecha→izquierda para eliminar. |
| **Perfil** | Email del usuario, historial de películas vistas, botón de logout. |

---

## 🏗️ Arquitectura

Arquitectura **Feature-First** con **Riverpod** como gestor de estado.

```
lib/
├── main.dart                        # Punto de entrada, inicialización Supabase + ProviderScope
├── core/
│   ├── constants/
│   │   ├── app_colors.dart          # Paleta de colores (tema Netflix)
│   │   └── app_constants.dart       # URLs, API keys, credenciales
│   ├── services/
│   │   ├── tmdb_service.dart        # Llamadas a la API de TMDB con Dio
│   │   └── supabase_service.dart    # Auth, favoritos, ratings, historial
│   └── router/
│       └── app_router.dart          # Navegación con go_router
├── models/
│   ├── movie.dart                   # Modelo de película con fromJson
│   └── user_movie.dart              # Favorito y entrada de historial
├── providers/                       # Riverpod providers (FutureProvider)
│   ├── auth_provider.dart
│   ├── movie_providers.dart
│   ├── favorites_provider.dart
│   └── profile_provider.dart
└── features/
    ├── auth/                        # LoginScreen, RegisterScreen
    ├── home/                        # HomeScreen, MainScaffold, widgets/
    ├── search/                      # SearchScreen
    ├── detail/                      # DetailScreen
    ├── favorites/                   # FavoritesScreen
    └── profile/                     # ProfileScreen
```

---

## 🔧 Tecnologías

| Tecnología | Uso |
|---|---|
| **Flutter 3** | Framework principal, UI multiplataforma |
| **Dart 3** | Lenguaje de programación |
| **Supabase Flutter 2.3** | Autenticación + base de datos PostgreSQL |
| **TMDB API v3** | Fuente de datos de películas |
| **flutter_riverpod 2.5** | Gestión de estado reactivo |
| **go_router 13** | Navegación declarativa con rutas nombradas |
| **dio 5.4** | Cliente HTTP para llamadas a TMDB |
| **cached_network_image 3.3** | Caché de imágenes de los posters |
| **shimmer 3.0** | Skeleton loaders en todas las listas |
| **flutter_rating_bar 4.0** | Widget de calificación con medias estrellas |

---

## 🗄️ Base de Datos (Supabase / PostgreSQL)

Tres tablas con Row Level Security activado. Solo se almacenan en Supabase los datos mínimos necesarios.

### `favorites`
| Columna | Tipo | Descripción |
|---|---|---|
| id | uuid (PK) | Identificador único |
| user_id | uuid (FK) | Referencia a `auth.users` |
| movie_id | int4 | ID de la película en TMDB |
| title | text | Título de la película |
| poster_path | text | Ruta del poster (TMDB) |
| genre_ids | int4[] | Array de IDs de géneros |
| created_at | timestamptz | Fecha de guardado |

### `user_ratings`
| Columna | Tipo | Descripción |
|---|---|---|
| id | uuid (PK) | Identificador único |
| user_id | uuid (FK) | Referencia a `auth.users` |
| movie_id | int4 | ID de la película en TMDB |
| rating | float8 | Calificación 0.5–5.0 |
| created_at | timestamptz | Fecha de calificación |

### `watch_history`
| Columna | Tipo | Descripción |
|---|---|---|
| id | uuid (PK) | Identificador único |
| user_id | uuid (FK) | Referencia a `auth.users` |
| movie_id | int4 | ID de la película en TMDB |
| title | text | Título de la película |
| poster_path | text | Ruta del poster (TMDB) |
| created_at | timestamptz | Fecha de visualización |

Todas las tablas tienen `UNIQUE(user_id, movie_id)` para evitar duplicados.

---

## 🚀 Instalación y configuración

### Pre-requisitos
- Flutter SDK 3.x
- Android Studio / VS Code
- Cuenta en [Supabase](https://supabase.com)
- API Key de [TMDB](https://www.themoviedb.org/settings/api)

### 1. Clonar el repositorio
```bash
git clone https://github.com/<tu-usuario>/peliculas.git
cd peliculas
```

### 2. Instalar dependencias
```bash
flutter pub get
```

### 3. Configurar credenciales
Editar `lib/core/constants/app_constants.dart` con tus propias keys.

### 4. Crear tablas en Supabase
Ejecutar el SQL que se encuentra en el comentario inicial de `lib/core/services/supabase_service.dart`.

### 5. Ejecutar
```bash
flutter run
```

---

## 📡 Endpoints TMDB utilizados

| Endpoint | Uso |
|---|---|
| `GET /3/movie/popular` | Películas populares (Home) |
| `GET /3/trending/movie/week` | Tendencias de la semana |
| `GET /3/search/movie?query=` | Búsqueda por texto |
| `GET /3/movie/{id}` | Detalle completo de una película |
| `GET /3/discover/movie?with_genres=` | Recomendaciones por género |

---

## 👤 Autor

Desarrollado como proyecto final del curso de **Aplicaciones Móviles**.
