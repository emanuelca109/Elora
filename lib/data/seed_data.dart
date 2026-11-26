import '../models/user_model.dart';
import '../models/product_model.dart';

class SeedData {
  static List<UserModel> get initialUsers => [
        UserModel(
          name: 'Administrador Elora',
          email: 'admin@elora.com',
          password: 'admin123',
          role: 'admin',
        ),
        UserModel(
          name: 'Emanuel Gómez',
          email: 'cliente@elora.com',
          password: 'cliente123',
          role: 'client',
        ),
      ];

  static List<ProductModel> get initialProducts => [
        ProductModel(
          name: 'Good Girl',
          category: 'Mujer',
          presentation: '80 ml',
          origin: 'Carolina Herrera',
          variety: 'Eau de Parfum',
          price: 450000.0,
          stock: 12,
          description:
              'Una fragancia icónica que combina audacia y sofisticación. Revela notas luminosas de nardo y jazmín sambac, contrastadas con los acordes oscuros e intensos de haba tonka y cacao.',
          imageUrl:
              'https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?auto=format&fit=crop&w=800&q=80',
        ),
        ProductModel(
          name: 'La Vie Est Belle',
          category: 'Mujer',
          presentation: '75 ml',
          origin: 'Lancôme',
          variety: 'Eau de Parfum',
          price: 420000.0,
          stock: 10,
          description:
              'Una declaración universal a la belleza de la vida. Con notas envolventes de iris noble, pachulí radiante y un exquisito acorde goloso de vainilla y praliné.',
          imageUrl:
              'https://images.unsplash.com/photo-1541643600914-78b084683601?auto=format&fit=crop&w=800&q=80',
        ),
        ProductModel(
          name: 'Miss Dior',
          category: 'Mujer',
          presentation: '100 ml',
          origin: 'Dior',
          variety: 'Eau de Parfum',
          price: 480000.0,
          stock: 8,
          description:
              'Un himno al amor y a la belleza. Una estela floral exuberante que reúne notas de rosa centifolia, lirio de los valles y peonía, abrazada por maderas tiernas.',
          imageUrl:
              'https://images.unsplash.com/photo-1588405748880-12d1d2a59f75?auto=format&fit=crop&w=800&q=80',
        ),
        ProductModel(
          name: 'Libre',
          category: 'Mujer',
          presentation: '90 ml',
          origin: 'Yves Saint Laurent',
          variety: 'Eau de Parfum',
          price: 460000.0,
          stock: 14,
          description:
              'El perfume de una mujer fuerte, audaz y libre. Una ardiente combinación de flor de azahar marroquí y lavanda francesa, rematada con ámbar gris y vainilla.',
          imageUrl:
              'https://images.unsplash.com/photo-1523293182086-7651a899d37f?auto=format&fit=crop&w=800&q=80',
        ),
        ProductModel(
          name: 'Sauvage',
          category: 'Hombre',
          presentation: '100 ml',
          origin: 'Dior',
          variety: 'Eau de Parfum',
          price: 490000.0,
          stock: 15,
          description:
              'Inspirado en el desierto a la hora mágica del crepúsculo. Notas chispeantes de bergamota de Reggio di Calabria y un rastro misterioso de absoluto de vainilla de Papúa.',
          imageUrl:
              'https://images.unsplash.com/photo-1594035910387-fea47794261f?auto=format&fit=crop&w=800&q=80',
        ),
        ProductModel(
          name: 'Bleu de Chanel',
          category: 'Hombre',
          presentation: '100 ml',
          origin: 'Chanel',
          variety: 'Parfum',
          price: 530000.0,
          stock: 6,
          description:
              'Un elogio a la libertad masculina a través de una fragancia aromática amaderada con notas nobles de cedro y sándalo de Nueva Caledonia.',
          imageUrl:
              'https://images.unsplash.com/photo-1527632984436-6132bc20703d?auto=format&fit=crop&w=800&q=80',
        ),
        ProductModel(
          name: 'Baccarat Rouge 540',
          category: 'Unisex',
          presentation: '70 ml',
          origin: 'M. Francis Kurkdjian',
          variety: 'Extrait de Parfum',
          price: 950000.0,
          stock: 4,
          description:
              'Una alquimia poética sublime. La brisa de jazmín y el brillo del azafrán realzan facetas minerales de ámbar gris y notas amaderadas de cedro recién cortado.',
          imageUrl:
              'https://images.unsplash.com/photo-1616949755610-8c9bbc08f138?auto=format&fit=crop&w=800&q=80',
        ),
        ProductModel(
          name: 'Discovery Coffret Elora',
          category: 'Sets',
          presentation: '5 x 10 ml',
          origin: 'Elora Luxury',
          variety: 'Set de Colección',
          price: 320000.0,
          stock: 20,
          description:
              'Una experiencia sensorial completa. Incluye 5 de nuestras fragancias más deseadas en viales de lujo recargables ideales para viaje o regalo.',
          imageUrl:
              'https://images.unsplash.com/photo-1595425970377-c9703cf48b6d?auto=format&fit=crop&w=800&q=80',
        ),
        ProductModel(
          name: 'Khamrah',
          category: 'Unisex',
          presentation: '100 ml',
          origin: 'Lattafa (Dubái)',
          variety: 'Eau de Parfum',
          price: 380000.0,
          stock: 18,
          description:
              'La joya oriental más codiciada de Dubái. Una apertura embriagadora de canela, nuez moscada y bergamota, con corazón de dátiles y praliné sobre un lecho cálido de vainilla, haba tonka y ámbar.',
          imageUrl:
              'https://images.unsplash.com/photo-1547887537-6158d64c35b3?auto=format&fit=crop&w=800&q=80',
        ),
        ProductModel(
          name: 'Asad',
          category: 'Hombre',
          presentation: '100 ml',
          origin: 'Lattafa (Dubái)',
          variety: 'Eau de Parfum',
          price: 360000.0,
          stock: 15,
          description:
              'Potencia, magnetismo y distinción árabe. Combina acordes intensos de pimienta negra, piña y tabaco con un corazón aromático de café e iris, culminando en maderas preciosas, benjuí y ámbar.',
          imageUrl:
              'https://images.unsplash.com/photo-1523293182086-7651a899d37f?auto=format&fit=crop&w=800&q=80',
        ),
        ProductModel(
          name: 'Yara',
          category: 'Mujer',
          presentation: '100 ml',
          origin: 'Lattafa (Dubái)',
          variety: 'Eau de Parfum',
          price: 350000.0,
          stock: 16,
          description:
              'Una fragancia oriental dulce, cremosa y ultra femenina. Despliega notas fascinantes de orquídea, heliotropo y mandarina radiante, envueltas en un acorde gourmand de frutas tropicales, vainilla y almizcle suave.',
          imageUrl:
              'https://images.unsplash.com/photo-1588405748880-12d1d2a59f75?auto=format&fit=crop&w=800&q=80',
        ),
        ProductModel(
          name: 'Bade\'e Al Oud (Oud for Glory)',
          category: 'Unisex',
          presentation: '100 ml',
          origin: 'Lattafa (Dubái)',
          variety: 'Eau de Parfum',
          price: 410000.0,
          stock: 10,
          description:
              'La máxima expresión de la realeza árabe. Magistral fusión de oud natural, lavanda fresca y azafrán dorado con notas de fondo de pachulí y almizcle que crean una estela imponente e inolvidable.',
          imageUrl:
              'https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?auto=format&fit=crop&w=800&q=80',
        ),
      ];
}
