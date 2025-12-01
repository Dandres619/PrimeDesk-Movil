# PrimeDesk Mobile

## 1. Instalación y Configuración ⚙️

### 1.1 Requisitos Previos

Se debe tener:

- **Flutter SDK** (recomendado 3.x o superior)
  - https://docs.flutter.dev/get-started/install
- **Dart** (incluido en Flutter)
- **Android Studio** o **VS Code**
- **Emulador Android** o dispositivo físico

### 1.2 Clonar el Repositorio

```bash
git clone https://github.com/Dandres619/PrimeDesk-Movil.git
cd PrimeDesk-Movil-main
```

### 1.3 Instalar Dependencias

```bash
flutter pub get
```

### 1.4 Ejecutar la Aplicación

```bash
flutter run
```

O simplemente presionando **F5** en tu editor.

---

## 2. Arquitectura del Proyecto 🏗️

El proyecto utiliza una estructura inspirada en **Clean Architecture**:

```
lib/
├── data/
├── domain/
└── presentation/
```

Esta separación facilita la **escalabilidad**, la **organización** y el **reemplazo futuro** de mock data por una API real.

---

## 3. Estructura y Responsabilidades 📁

```
lib/
├── main.dart
├── data/
│   ├── mock_data/
│   └── models/
├── domain/
│   └── providers/
└── presentation/
    ├── screens/
    └── widgets/
```

### 3.1 `/data/`

Contiene los **modelos del dominio** y los **datos mock** usados para pruebas locales.

Incluye entidades como:

- Usuarios
- Productos
- Motos
- Proveedores
- Categorías
- Pedidos de servicios
- Compras y ventas
- Horarios

Los datos mock permiten ejecutar toda la aplicación **sin backend**.

### 3.2 `/domain/providers/`

Aloja la **capa de lógica de negocio** mediante Notifiers (manejo de estado).

Ejemplos de notifiers:

- `auth_notifier.dart`
- `user_management_notifier.dart`
- `appointment_notifier.dart`
- `category_notifier.dart`
- `cart_notifier.dart`
- etc.

Cada Notifier:

- Gestiona datos en memoria
- Expone estados a la UI
- Notifica cambios mediante `notifyListeners()`

Es un enfoque **simple**, **robusto** y **perfecto** para CRUD y dashboards administrativos.

### 3.3 `/presentation/`

Contiene la **interfaz de usuario (UI)**.

#### `/screens/`

Pantallas principales del sistema, como:

- Agendamientos
- Categorías
- Clientes
- Compras
- Horarios
- Motos
- Pedidos de Servicios
- Proveedores
- Productos
- Usuarios
- Ventas
- Home
- Login

#### `/widgets/`

Componentes reutilizables, por ejemplo:

- `custom_app_bar.dart`

---

## 4. Arquitectura de Estados 🔄

El proyecto utiliza:

**Provider + ChangeNotifier**

### Ventajas:

- ✅ Estado reactivo fácil de implementar
- ✅ Separación clara UI / lógica
- ✅ Excelente para CRUD administrativos
- ✅ Curva de aprendizaje baja

### Flujo estándar:

1. Un **Notifier** contiene el estado (lista de productos, usuarios, …)
2. La **UI** consume el estado vía `Consumer` o `Provider.of`
3. Si cambia algo → `notifyListeners()` → la **UI se reconstruye automáticamente**
