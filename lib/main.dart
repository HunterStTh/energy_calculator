
import 'package:flutter/material.dart';

// Главная функция приложения - точка входа
void main() {
  // Запуск приложения с корневым виджетом MyApp
  runApp(const MyApp());
}

// Корневой виджет приложения
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Построение дерева виджетов Material Design
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Калькулятор кинетической энергии',
      theme: ThemeData(
        // Настройка цветовой схемы приложения
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true, // Использовать Material 3 дизайн
      ),
      // Стартовый экран приложения
      home: const EnergyCalculatorScreen(),
    );
  }
}

// Экран калькулятора Stateful Widget для управления состоянием
class EnergyCalculatorScreen extends StatefulWidget {
  const EnergyCalculatorScreen({super.key});

  // Создание состояния для виджета
  @override
  State<EnergyCalculatorScreen> createState() => _EnergyCalculatorScreenState();
}

// Класс состояния для экрана калькулятора
class _EnergyCalculatorScreenState extends State<EnergyCalculatorScreen> {
  // Ключ для управления состоянием формы
  final _formKey = GlobalKey<FormState>();
  
  // Контроллеры для полей ввода
  final TextEditingController _massController = TextEditingController();
  final TextEditingController _velocityController = TextEditingController();
  
  // Состояние чекбокса согласия
  bool _agreementChecked = false;
  
  // Выбранная система единиц CИ
  String? _unitSystem = 'si';

  // Константы для конвертации единиц:
  static const double poundsToKg = 0.453592; // 1 фунт = 0.453592 кг
  static const double mphToMs = 0.44704;  // 1 миля/час = 0.44704 м/с
  static const double kmhToMs = 0.277778; // 1 км/ч = 0.277778 м/с

  // Метод расчета кинетической энергии
  void _calculateEnergy() {
    // Проверка валидности формы и наличия согласия
    if (_formKey.currentState!.validate() && _agreementChecked) {
      // Получение значений из полей ввода
      double mass = double.parse(_massController.text);
      double velocity = double.parse(_velocityController.text);
      
      // Конвертация в СИ если выбрана английская система
      if (_unitSystem == 'si') {
        velocity *= kmhToMs; // Конвертация км/ч → м/с
      } else if (_unitSystem == 'imperial') {
        mass *= poundsToKg;  // Конвертация массы в кг
        velocity *= mphToMs;   // Конвертация скорости в м/с
      }
      
      // Расчет энергии по формуле: E = ½mv²
      final energy = 0.5 * mass * velocity * velocity;

      // Переход на экран результатов с передачей параметров
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            mass: mass,
            velocity: velocity,
            energy: energy,
            unitSystem: _unitSystem!,
            originalMass: double.parse(_massController.text),
            originalVelocity: double.parse(_velocityController.text),
          ),
        ),
      );
    } else if (!_agreementChecked) {
      // Показать сообщение об ошибке если нет согласия
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Необходимо согласие на обработку данных'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Построение интерфейса экрана
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Верхняя панель приложения
      appBar: AppBar(
        title: const Text('Калькулятор кинетической энергии'),
        centerTitle: true, // Центрирование заголовка
        actions: [
          // Отображение ФИО в правой части AppBar
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Гаврилов Д.А.', 
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      // Основное содержимое экрана
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Привязка ключа формы
          child: ListView(
            children: [
              // Поле ввода массы
              const SizedBox(height: 20),
              TextFormField(
                controller: _massController,
                keyboardType: TextInputType.number, // Цифровая клавиатура
                decoration: InputDecoration(
                  labelText: 'Масса тела',
                  border: const OutlineInputBorder(),
                  suffixText: _unitSystem == 'si' ? 'кг' : 'фунты',
                ),
                // Валидатор для поля ввода массы
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Введите массу тела';
                  final mass = double.tryParse(value!);
                  return mass == null || mass <= 0 
                    ? 'Введите корректное значение массы' 
                    : null;
                },
              ),
              
              // Поле ввода скорости
              const SizedBox(height: 20),
              TextFormField(
                controller: _velocityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Скорость',
                  border: const OutlineInputBorder(),
                  suffixText: _unitSystem == 'si' ? 'км/ч' : 'миль/ч',
                ),
                // Валидатор для поля ввода скорости
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Введите скорость';
                  final velocity = double.tryParse(value!);
                  return velocity == null || velocity < 0 
                    ? 'Введите корректное значение скорости' 
                    : null;
                },
              ),
              
              // Выбор системы единиц
              const SizedBox(height: 20),
              const Text('Система единиц:'),
              RadioListTile(
                title: const Text('СИ (кг, км/ч)'),
                value: 'si',
                groupValue: _unitSystem,
                onChanged: (value) => setState(() => _unitSystem = value),
              ),
              RadioListTile(
                title: const Text('Английская (фунты, миль/ч)'),
                value: 'imperial',
                groupValue: _unitSystem,
                onChanged: (value) => setState(() => _unitSystem = value),
              ),
              
              // Чекбокс согласия
              const SizedBox(height: 20),
              CheckboxListTile(
                title: const Text('Согласен на обработку данных'),
                value: _agreementChecked,
                onChanged: (value) => setState(() => _agreementChecked = value!),
              ),
              
              // Кнопка расчета
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _calculateEnergy,
                child: const Text('Рассчитать'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Экран отображения результатов
class ResultScreen extends StatelessWidget {
  // Параметры экрана:
  final double mass; // Масса в кг (после конвертации)
  final double velocity;// Скорость в м/с (после конвертации)
  final double energy;  // Энергия в Дж
  final String unitSystem;  // Использованная система единиц
  final double originalMass;  // Исходная масса (до конвертации)
  final double originalVelocity; // Исходная скорость (до конвертации)

  const ResultScreen({
    super.key,
    required this.mass,
    required this.velocity,
    required this.energy,
    required this.unitSystem,
    required this.originalMass,
    required this.originalVelocity,
  });

  // Построение интерфейса экрана результатов
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Результат расчета'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Гаврилов Д.А.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Отображение массы
              Text(
                'Масса: ${originalMass.toStringAsFixed(2)} ${unitSystem == 'si' ? 'кг' : 'фунтов'}',
                style: const TextStyle(fontSize: 20),
              ),
              
              // Отображение скорости
              const SizedBox(height: 10),
              Text(
                'Скорость: ${originalVelocity.toStringAsFixed(2)} ${unitSystem == 'si' ? 'км/ч' : 'миль/ч'}',
                style: const TextStyle(fontSize: 20),
              ),
              
              // Отображение результата
              const SizedBox(height: 20),
              Text(
                'Кинетическая энергия:',
                style: const TextStyle(fontSize: 20),
              ),
              Text(
                '${energy.toStringAsFixed(2)} Дж',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              
              // Дополнительная информация для английской системы
              if (unitSystem == 'imperial') ...[
                const SizedBox(height: 20),
                const Text(
                  '(Конвертировано в СИ)',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  '${originalMass.toStringAsFixed(2)} фунтов = ${mass.toStringAsFixed(2)} кг',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  '${originalVelocity.toStringAsFixed(2)} миль/ч = ${velocity.toStringAsFixed(2)} м/с',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
              
              // Дополнительная информация для системы СИ
              if (unitSystem == 'si') ...[
                const SizedBox(height: 20),
                const Text(
                  '(Конвертировано в м/с)',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  '${originalVelocity.toStringAsFixed(2)} км/ч = ${velocity.toStringAsFixed(2)} м/с',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
              
              // Кнопка возврата
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Назад'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 