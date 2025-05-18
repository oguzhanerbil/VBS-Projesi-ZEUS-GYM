import 'package:flutter/material.dart';
import 'package:gym/providers/trainer_provider.dart';
import 'package:provider/provider.dart';
import '../../providers/class_provider.dart';
import '../../models/class.dart';

class ClassScheduleManagementScreen extends StatefulWidget {
  const ClassScheduleManagementScreen({super.key});

  @override
  State<ClassScheduleManagementScreen> createState() =>
      _ClassScheduleManagementScreenState();
}

class _ClassScheduleManagementScreenState
    extends State<ClassScheduleManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _classNameController = TextEditingController();
  String? _selectedDay;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  int? _selectedTrainerId;

  final List<String> _weekDays = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final classProvider = Provider.of<ClassProvider>(context, listen: false);
    await classProvider.loadAllClasses();

    final trainerProvider = Provider.of<TrainerProvider>(
      context,
      listen: false,
    );
    await trainerProvider.loadTrainers();
  }

  @override
  void dispose() {
    _classNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          image: DecorationImage(
            image: const AssetImage('assets/images/background.jpeg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Başlık barı
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Expanded(
                      child: Text(
                        'Ders Programı Yönetimi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // İçerik
              Expanded(
                child: Consumer<ClassProvider>(
                  builder: (context, classProvider, child) {
                    if (classProvider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      );
                    }

                    final classes = classProvider.allClasses;

                    return Column(
                      children: [
                        // Ders listesi
                        Expanded(
                          child:
                              classes.isEmpty
                                  ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.calendar_today,
                                          color: Colors.white,
                                          size: 72,
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Henüz ders programı oluşturulmadı.',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton(
                                          onPressed:
                                              () => _showClassDialog(context),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                  255,
                                                  23,
                                                  25,
                                                  53,
                                                ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text(
                                            'Yeni Ders Ekle',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  : ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: classes.length,
                                    itemBuilder: (context, index) {
                                      final classItem = classes[index];
                                      return Card(
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        color: Colors.white.withOpacity(0.1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: ListTile(
                                          contentPadding: const EdgeInsets.all(
                                            16,
                                          ),
                                          title: Text(
                                            classItem.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.calendar_today,
                                                    color: Colors.white70,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    classItem.dayOfWeek,
                                                    style: const TextStyle(
                                                      color: Colors.white70,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.access_time,
                                                    color: Colors.white70,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    classItem.startTime,
                                                    style: const TextStyle(
                                                      color: Colors.white70,
                                                    ),
                                                  ),
                                                  const Text(
                                                    ' - ',
                                                    style: TextStyle(
                                                      color: Colors.white70,
                                                    ),
                                                  ),
                                                  Text(
                                                    classItem.endTime,
                                                    style: const TextStyle(
                                                      color: Colors.white70,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.person,
                                                    color: Colors.white70,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    classItem.trainerName ??
                                                        'Eğitmen atanmadı',
                                                    style: const TextStyle(
                                                      color: Colors.white70,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  color: Colors.white70,
                                                ),
                                                onPressed:
                                                    () => _showClassDialog(
                                                      context,
                                                      classItem,
                                                    ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.white70,
                                                ),
                                                onPressed:
                                                    () => _showDeleteDialog(
                                                      context,
                                                      classItem,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                        ),

                        // Alt buton barı
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton(
                            onPressed: () => _showClassDialog(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                23,
                                25,
                                53,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'YENİ DERS EKLE',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showClassDialog(BuildContext context, [Class? classToEdit]) {
    // Dialog açıldığında, düzenleme modundaysak değerleri doldur
    if (classToEdit != null) {
      _classNameController.text = classToEdit.name;
      _selectedDay = classToEdit.dayOfWeek;

      // Saatleri ayarla
      final startTimeParts = classToEdit.startTime.split(':');
      final endTimeParts = classToEdit.endTime.split(':');

      _startTime = TimeOfDay(
        hour: int.parse(startTimeParts[0]),
        minute: int.parse(startTimeParts[1]),
      );

      _endTime = TimeOfDay(
        hour: int.parse(endTimeParts[0]),
        minute: int.parse(endTimeParts[1]),
      );

      _selectedTrainerId = classToEdit.trainerId;
    } else {
      // Yeni ders ekleniyorsa değerleri sıfırla
      _classNameController.text = '';
      _selectedDay = null;
      _startTime = const TimeOfDay(hour: 9, minute: 0);
      _endTime = const TimeOfDay(hour: 10, minute: 0);
      _selectedTrainerId = null;
    }

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 23, 25, 53),
          title: Text(
            classToEdit == null ? 'Yeni Ders Ekle' : 'Dersi Düzenle',
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _classNameController,
                    decoration: const InputDecoration(
                      labelText: 'Ders Adı',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen bir ders adı girin';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedDay,
                    decoration: const InputDecoration(
                      labelText: 'Gün',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white30),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    dropdownColor: const Color.fromARGB(255, 23, 25, 53),
                    style: const TextStyle(color: Colors.white),
                    items:
                        _weekDays.map((day) {
                          return DropdownMenuItem<String>(
                            value: day,
                            child: Text(day),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDay = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen bir gün seçin';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Consumer<ClassProvider>(
                    builder: (context, provider, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: provider.startTime,
                                  builder:
                                      (context, child) => Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: const ColorScheme.dark(
                                            primary: Colors.white,
                                            onPrimary: Color.fromARGB(
                                              255,
                                              23,
                                              25,
                                              53,
                                            ),
                                            onSurface: Colors.white,
                                          ),
                                        ),
                                        child: child!,
                                      ),
                                );
                                if (time != null) {
                                  provider.updateStartTime(time);
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Başlangıç Saati',
                                  labelStyle: TextStyle(color: Colors.white70),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white30,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  '${provider.startTime.hour.toString().padLeft(2, '0')}:${provider.startTime.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: provider.endTime,
                                  builder:
                                      (context, child) => Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: const ColorScheme.dark(
                                            primary: Colors.white,
                                            onPrimary: Color.fromARGB(
                                              255,
                                              23,
                                              25,
                                              53,
                                            ),
                                            onSurface: Colors.white,
                                          ),
                                        ),
                                        child: child!,
                                      ),
                                );
                                if (time != null) {
                                  provider.updateEndTime(time);
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Bitiş Saati',
                                  labelStyle: TextStyle(color: Colors.white70),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white30,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  '${provider.endTime.hour.toString().padLeft(2, '0')}:${provider.endTime.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Consumer<TrainerProvider>(
                    builder: (context, trainerProvider, child) {
                      return Consumer<ClassProvider>(
                        builder: (context, classProvider, child) {
                          return DropdownButtonFormField<int>(
                            value: classProvider.selectedTrainerId,
                            decoration: const InputDecoration(
                              labelText: 'Eğitmen',
                              labelStyle: TextStyle(color: Colors.white70),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white30),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            dropdownColor: const Color.fromARGB(
                              255,
                              23,
                              25,
                              53,
                            ),
                            style: const TextStyle(color: Colors.white),
                            items:
                                trainerProvider.trainers.map((trainer) {
                                  print("id değeri: ${trainer.id}");
                                  return DropdownMenuItem<int>(
                                    value: trainer.id,
                                    child: Text(
                                      '${trainer.name} ${trainer.surname}',
                                    ),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              classProvider.updateSelectedTrainer(value);
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Lütfen bir eğitmen seçin';
                              }
                              return null;
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'İptal',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final classProvider = Provider.of<ClassProvider>(
                    context,
                    listen: false,
                  );

                  final startTimeStr =
                      '${classProvider.startTime.hour.toString().padLeft(2, '0')}:${classProvider.startTime.minute.toString().padLeft(2, '0')}';
                  final endTimeStr =
                      '${classProvider.endTime.hour.toString().padLeft(2, '0')}:${classProvider.endTime.minute.toString().padLeft(2, '0')}';

                  bool success;
                  // Kaydetme butonunda
                  if (classToEdit == null) {
                    // Yeni ders ekle
                    success = await classProvider.addClass(
                      _classNameController.text,
                      _selectedDay!,
                      startTimeStr,
                      endTimeStr,
                      classProvider
                          .selectedTrainerId!, // _selectedTrainerId yerine provider'dan al
                    );
                  } else {
                    // Dersi güncelle
                    success = await classProvider.updateClass(
                      classToEdit.id!,
                      _classNameController.text,
                      _selectedDay!,
                      startTimeStr,
                      endTimeStr,
                      classProvider
                          .selectedTrainerId!, // _selectedTrainerId yerine provider'dan al
                    );
                  }

                  if (success && mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          classToEdit == null
                              ? 'Ders başarıyla eklendi!'
                              : 'Ders başarıyla güncellendi!',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Hata: ${classProvider.error ?? "Bilinmeyen bir hata oluştu"}',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              child: Text(
                classToEdit == null ? 'EKLE' : 'GÜNCELLE',
                style: const TextStyle(color: Color.fromARGB(255, 23, 25, 53)),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, Class classItem) {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color.fromARGB(255, 23, 25, 53),
            title: const Text(
              'Dersi Sil',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              '${classItem.name} dersini silmek istediğinize emin misiniz?',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'İptal',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              TextButton(
                onPressed: () async {
                  final classProvider = Provider.of<ClassProvider>(
                    context,
                    listen: false,
                  );
                  final success = await classProvider.deleteClass(
                    classItem.id!,
                  );

                  if (success && mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ders başarıyla silindi!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Hata: ${classProvider.error ?? "Bilinmeyen bir hata oluştu"}',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('SİL'),
              ),
            ],
          ),
    );
  }
}
