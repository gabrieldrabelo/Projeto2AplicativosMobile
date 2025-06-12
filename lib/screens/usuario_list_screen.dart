import 'package:flutter/material.dart';
import '../controllers/usuario_controller.dart';
import '../models/usuario.dart';
import '../widgets/custom_text_field.dart';

class UsuarioListScreen extends StatefulWidget {
  const UsuarioListScreen({Key? key}) : super(key: key);

  @override
  _UsuarioListScreenState createState() => _UsuarioListScreenState();
}

class _UsuarioListScreenState extends State<UsuarioListScreen> {
  final UsuarioController _controller = UsuarioController();
  List<Usuario> _usuarios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsuarios();
  }

  Future<void> _loadUsuarios() async {
    setState(() {
      _isLoading = true;
    });

    final usuarios = await _controller.getAll();

    setState(() {
      _usuarios = usuarios;
      _isLoading = false;
    });
  }

  void _showUsuarioForm({Usuario? usuario}) {
    final formKey = GlobalKey<FormState>();
    final idController = TextEditingController(text: usuario?.id ?? '');
    final senhaController = TextEditingController(text: usuario?.senha ?? '');
    final nomeController = TextEditingController(text: usuario?.nome ?? '');
    final bool isEditing = usuario != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Editar Usuário' : 'Novo Usuário'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  label: 'ID',
                  controller: idController,
                  isRequired: true,
                  enabled: !isEditing,
                ),
                CustomTextField(
                  label: 'Senha',
                  controller: senhaController,
                  isRequired: true,
                  obscureText: true,
                ),
                CustomTextField(
                  label: 'Nome',
                  controller: nomeController,
                  isRequired: true,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final newUsuario = Usuario(
                  id: idController.text,
                  senha: senhaController.text,
                  nome: nomeController.text,
                );

                bool success;
                if (isEditing) {
                  success = await _controller.update(newUsuario);
                } else {
                  success = await _controller.add(newUsuario);
                }

                Navigator.pop(context);

                if (success) {
                  _loadUsuarios();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Usuário ${isEditing ? 'atualizado' : 'adicionado'} com sucesso!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Erro ao ${isEditing ? 'atualizar' : 'adicionar'} usuario')),
                  );
                }
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUsuario(Usuario usuario) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmar excluir'),
            content: Text(
                'Tem certeza que deseja excluir o usuário ${usuario.nome}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Excluir'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed) {
      final success = await _controller.delete(usuario.id);

      if (success) {
        _loadUsuarios();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário excluido com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao excluir usuário')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuario'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _usuarios.isEmpty
              ? const Center(child: Text('Nenhum usuário cadastrado'))
              : ListView.builder(
                  itemCount: _usuarios.length,
                  itemBuilder: (context, index) {
                    final usuario = _usuarios[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(usuario.nome),
                        subtitle: Text('ID: ${usuario.id}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () =>
                                  _showUsuarioForm(usuario: usuario),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteUsuario(usuario),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUsuarioForm(),
        tooltip: 'Adicionar Usuário',
        child: const Icon(Icons.add),
      ),
    );
  }
}