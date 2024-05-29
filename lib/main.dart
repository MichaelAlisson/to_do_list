import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Checklist App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'TO DO LIST',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 30.0,
            ),
          ),
          backgroundColor: Color.fromARGB(255, 0, 110, 173),
        ),
        body: ChecklistPage(),
      ),
    );
  }
}

class ChecklistPage extends StatefulWidget {
  @override
  _ChecklistPageState createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  // Lista para armazenar tarefas (título, descrição e status)
  List<Map<String, dynamic>> tasks = [];

  // Lista para armazenar tarefas arquivadas
  List<Map<String, dynamic>> archivedTasks = [];

  // Controlador para o campo de texto de nova tarefa
  final _taskController = TextEditingController();

  // Adiciona uma nova tarefa à lista de tarefas
  void addTask(String title, String description) {
    setState(() {
      // Adiciona um novo mapa contendo título, descrição e status "Para fazer" à lista de tarefas
      tasks.add({
        'title':
            title, // Use 'title' para consistência (garante a chave correta)
        'description': description,
        'status':
            'Para fazer', // Use 'Para fazer' para clareza (define o status padrão)
      });
      // Limpa o campo de texto após adicionar a tarefa
      _taskController.clear();
    });
  }

  // Atualiza o status de uma tarefa na lista
  void updateTaskStatus(int index, String newStatus) {
    setState(() {
      // Acessa a tarefa específica pelo índice
      final task = tasks[index];
      // Atualiza o status da tarefa
      task['status'] = newStatus;

      // Arquiva a tarefa se o novo status for "Feito"
      if (newStatus == 'Feito') {
        archiveTask(index);
      }
    });
  }

  // Move a tarefa para a lista de tarefas arquivadas
  void archiveTask(int index) {
    setState(() {
      // Adiciona a tarefa atual à lista de tarefas arquivadas
      archivedTasks.add(tasks[index]);
      // Remove a tarefa da lista principal de tarefas
      tasks.removeAt(index);
    });
  }

  // Exibe as tarefas arquivadas em um diálogo
  void showArchivedTasks() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tarefas arquivadas'),
        content: ListView.builder(
          // Constrói uma lista de tarefas arquivadas
          shrinkWrap: true,
          itemCount: archivedTasks.length,
          itemBuilder: (context, index) {
            final task = archivedTasks[index];
            return ListTile(
              title: Text(task['title']),
              subtitle: Text(task['description']),
              trailing: IconButton(
                icon: Icon(Icons.unarchive),
                onPressed: () {
                  setState(() {
                    tasks.add(task);
                    archivedTasks.removeAt(index);
                  });
                  Navigator.of(context).pop();
                },
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _taskController,
                  decoration: InputDecoration(
                    hintText: 'Qual sua tarefa?',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: 8.0),
              ElevatedButton(
                onPressed: () {
                  if (_taskController.text.isNotEmpty) {
                    addTask(_taskController.text, '');
                  }
                },
                child: Text('NOVA', style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          'Pra fazer',
                          style: TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: tasks
                              .where((task) => task['status'] == 'Para fazer')
                              .length,
                          itemBuilder: (context, index) {
                            final task = tasks
                                .where((task) => task['status'] == 'Para fazer')
                                .toList()[index];
                            return ListTile(
                              key: UniqueKey(), // Add unique key for each item
                              title: Text(task['title']),
                              subtitle: Text(task['description']),
                              trailing: DropdownButton<String>(
                                value: task['status'],
                                onChanged: (newStatus) {
                                  updateTaskStatus(
                                      tasks.indexOf(task), newStatus!);
                                },
                                items: ['Para fazer', 'Fazendo', 'Feito']
                                    .map((status) => DropdownMenuItem(
                                          value: status,
                                          child: Text(status),
                                        ))
                                    .toList(),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          'Fazendo',
                          style: TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: tasks
                              .where((task) => task['status'] == 'Fazendo')
                              .length,
                          itemBuilder: (context, index) {
                            final task = tasks
                                .where((task) => task['status'] == 'Fazendo')
                                .toList()[index];
                            return ListTile(
                              key:
                                  UniqueKey(), // Adicione uma chave exclusiva para cada item
                              title: Text(task['title']),
                              subtitle: Text(task['description']),
                              trailing: DropdownButton<String>(
                                value: task['status'],
                                onChanged: (newStatus) {
                                  updateTaskStatus(
                                      tasks.indexOf(task), newStatus!);
                                },
                                items: ['Para fazer', 'Fazendo', 'Feito']
                                    .map((status) => DropdownMenuItem(
                                          value: status,
                                          child: Text(status),
                                        ))
                                    .toList(),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          'Feito',
                          style: TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: tasks
                              .where((task) => task['status'] == 'Feito')
                              .length,
                          itemBuilder: (context, index) {
                            final task = tasks
                                .where((task) => task['status'] == 'Feito')
                                .toList()[index];
                            return ListTile(
                              key: UniqueKey(), // Add unique key for each item
                              title: Text(task['title']),
                              subtitle: Text(task['description']),
                              trailing: DropdownButton<String>(
                                value: task['status'],
                                onChanged: (newStatus) {
                                  updateTaskStatus(
                                      tasks.indexOf(task), newStatus!);
                                },
                                items: ['Para fazer', 'Fazendo', 'Feito']
                                    .map((status) => DropdownMenuItem(
                                          value: status,
                                          child: Text(status),
                                        ))
                                    .toList(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: showArchivedTasks,
              icon: Icon(Icons.archive, color: Colors.black),
              label: Text('Ver arquivadas'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue[200]),
                padding: MaterialStateProperty.all(EdgeInsets.all(12.0)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
