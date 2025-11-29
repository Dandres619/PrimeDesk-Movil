import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/moto_model.dart';
import '../models/service_order_model.dart';


// ====================================================================
// SECCIÓN 1: Datos Mock de Usuarios (Administradores, Mecánicos y Clientes)
// Definición de usuarios de prueba con roles específicos para login y pruebas
// ====================================================================

final List<UserModel> mockUsers = [
  /// Usuario administrador con permisos completos en el sistema
  const UserModel(
    id: 1,
    name: 'Isabella Gómez',
    email: 'admin@taller.com',
    role: 'Administrador',
    telefono: '3001234567',
    token: 'token_admin',
  ),

  /// Mecánico del taller con permisos para gestionar servicios
  const UserModel(
    id: 2,
    name: 'Ricardo Mecánico',
    email: 'mecanico@taller.com',
    role: 'Mecánico',
    telefono: '3009876543',
    token: 'token_mec',
  ),

  /// Cliente con motocicleta registrada
  const UserModel(
    id: 3,
    name: 'Andrés Cliente',
    email: 'andres.c@mail.com',
    role: 'Cliente',
    telefono: '3001112233',
    token: 'token_cli_3',
  ),

  /// Cliente con motocicleta registrada
  const UserModel(
    id: 4,
    name: 'Daniela Ríos',
    email: 'daniela.rios@mail.com',
    role: 'Cliente',
    telefono: '3105551234',
    token: 'token_cli_4',
  ),

  /// Cliente sin motocicletas asociadas
  const UserModel(
    id: 5,
    name: 'Jorge Valencia',
    email: 'jorge.v@mail.com',
    role: 'Cliente',
    telefono: '3201119988',
    token: 'token_cli_5',
  ),
];

/// Lista auxiliar de mecánicos filtrada desde mockUsers
final List<UserModel> mockMechanics =
    mockUsers.where((u) => u.role == 'Mecánico').toList();


// ====================================================================
// SECCIÓN 2: Datos Mock de Categorías
// Categorías utilizadas para clasificación y filtrado de productos
// ====================================================================

final List<CategoryModel> mockCategoriesData = [
  CategoryModel(
    id: 1,
    name: 'Lubricantes',
    description: 'Aceites y fluidos.',
    isActive: true,
  ),
  CategoryModel(
    id: 2,
    name: 'Filtros',
    description: 'Filtros de aire, aceite y combustible.',
    isActive: true,
  ),
  CategoryModel(
    id: 3,
    name: 'Frenos',
    description: 'Pastillas, discos y líquidos.',
    isActive: true,
  ),
  CategoryModel(
    id: 4,
    name: 'Neumáticos',
    description: 'Todo tipo de neumáticos.',
    isActive: false,
  ),
  CategoryModel(
    id: 5,
    name: 'Electricidad',
    description: 'Baterías, bujías y componentes eléctricos.',
    isActive: true,
  ),
  CategoryModel(
    id: 6,
    name: 'Accesorios',
    description: 'Elementos de mejora estética y confort.',
    isActive: true,
  ),
];


// ====================================================================
// SECCIÓN 3: Datos Mock de Productos
// Información de productos disponibles con stock, precio y categoría
// ====================================================================

final List<ProductModel> mockProducts = [
  ProductModel(
    id: 101,
    name: 'Aceite Motor Sintético 10W-40',
    price: 45.99,
    stock: 50,
    category: 'Lubricantes',
    isAvailable: true,
  ),
  ProductModel(
    id: 201,
    name: 'Filtro de Aire Deportivo K&N',
    price: 75.00,
    stock: 12,
    category: 'Filtros',
    isAvailable: true,
  ),
  ProductModel(
    id: 301,
    name: 'Pastillas de Freno Cerámicas (Juego)',
    price: 120.99,
    stock: 3,
    category: 'Frenos',
    isAvailable: true,
  ),
  ProductModel(
    id: 501,
    name: 'Batería 12V Gel Alto Rendimiento',
    price: 89.99,
    stock: 5,
    category: 'Electricidad',
    isAvailable: true,
  ),
  ProductModel(
    id: 704,
    name: 'Tornillo de Drenaje Magnético',
    price: 9.50,
    stock: 90,
    category: 'Lubricantes',
    isAvailable: true,
  ),
  ProductModel(
    id: 601,
    name: 'Kit de Limpieza Completo',
    price: 45.00,
    stock: 60,
    category: 'Accesorios',
    isAvailable: true,
  ),
];

/// Lista de nombres de categorías generada automáticamente para filtros
final List<String> mockCategories =
    mockProducts.map((p) => p.category).toSet().toList();


// ====================================================================
// SECCIÓN 4: Datos Mock de Motos
// Motocicletas registradas asociadas a distintos clientes
// ====================================================================

final List<MotoModel> mockMotos = [
  MotoModel(
    id: 1,
    clientId: 3,
    placa: 'FDN123',
    marca: 'Yamaha',
    modelo: 'MT-07',
    anio: 2020,
    color: 'Negro',
    vin: 'VINYMT072020A',
    isActive: true,
  ),
  MotoModel(
    id: 2,
    clientId: 4,
    placa: 'ABC456',
    marca: 'Honda',
    modelo: 'CB500X',
    anio: 2022,
    color: 'Rojo',
    vin: 'VINHCB500X2022B',
    isActive: true,
  ),
  MotoModel(
    id: 3,
    clientId: 3,
    placa: 'XYZ789',
    marca: 'Kawasaki',
    modelo: 'Ninja 400',
    anio: 2018,
    color: 'Verde',
    vin: 'VINKNIN4002018C',
    isActive: false,
  ),
];


// ====================================================================
// SECCIÓN 5: Datos Mock de Órdenes de Servicio
// Órdenes con distintos estados para pruebas de flujo de trabajo
// ====================================================================

final List<ServiceOrderModel> mockServiceOrders = [
  ServiceOrderModel(
    id: 1,
    motoId: 1,
    clientName: 'Andrés Cliente',
    motoPlaca: 'FDN123',
    mechanicName: 'Ricardo Mecánico',
    status: 'En Progreso',
    entryDate: DateTime.now().subtract(const Duration(days: 2)),
    workDescription: 'Cambio de kit de arrastre y revisión general.',
  ),
  ServiceOrderModel(
    id: 2,
    motoId: 2,
    clientName: 'Daniela Ríos',
    motoPlaca: 'ABC456',
    mechanicName: 'Ricardo Mecánico',
    status: 'Pendiente',
    entryDate: DateTime.now().subtract(const Duration(hours: 5)),
    workDescription: 'Cambio de aceite y filtro (mantenimiento preventivo).',
  ),
  ServiceOrderModel(
    id: 3,
    motoId: 3,
    clientName: 'Andrés Cliente',
    motoPlaca: 'XYZ789',
    mechanicName: 'Ricardo Mecánico',
    status: 'Finalizado',
    entryDate: DateTime.now().subtract(const Duration(days: 7)),
    workDescription: 'Reparación de motor por sobrecalentamiento.',
  ),
];
