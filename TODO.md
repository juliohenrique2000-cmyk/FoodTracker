# TODO: Implementar edição de alimentos na despensa

- [ ] Modificar ListTile no _buildPantryList para incluir botão de editar (usando Row com ícones de editar e deletar)
- [ ] Adicionar função _editPantryItem(PantryItem item) que abre o dialog de edição
- [ ] Modificar AddPantryItemDialog para aceitar parâmetro opcional PantryItem? itemToEdit
- [ ] Preencher campos no dialog se itemToEdit for fornecido e mudar título para "Editar Alimento"
- [ ] Atualizar _submitForm para chamar onItemEdited se for edição
- [ ] Adicionar callback onItemEdited no PantryScreen que faz PUT request e recarrega lista
- [ ] Testar funcionalidade de edição
