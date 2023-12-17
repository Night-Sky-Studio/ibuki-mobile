import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ibuki/classes/helpers.dart';
import 'package:ibuki/classes/settings.dart';
import 'package:ibuki/classes/widgets/material_icon_button.dart';

class AccountsPage extends HookWidget {
    const AccountsPage({super.key, required this.settings});
    final Settings settings;

    @override
    Widget build(BuildContext context) {
        final accounts = useState<List<Account>>(settings.accounts);
        final username = useState(""),
              password = useState(""),
              booruId = useState(settings.activeBooru!.id),
              isApiKey = useState(false);

        final formKey = GlobalKey<FormState>();

        Widget makeLoginDialog(BuildContext context) =>
            AlertDialog(content: Form(key: formKey, child: SizedBox(width: 256,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                        DropdownMenu<int>(
                            dropdownMenuEntries: settings.boorus.map<DropdownMenuEntry<int>>((e) => DropdownMenuEntry<int>(
                                value: e.id, 
                                label: e.name!,
                                leadingIcon: processIcon(e.icon, size: 32)
                            )).toList(),
                            width: 256,
                            onSelected: (value) => booruId.value = value as int, 
                            leadingIcon: Container(padding: const EdgeInsets.all(8),child: processIcon(settings.getBooruById(booruId.value)?.icon),),
                            initialSelection: booruId.value
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                            decoration: const InputDecoration(
                                labelText: "Username",
                                border: OutlineInputBorder()
                            ),
                            onChanged: (value) => username.value = value,
                            validator: (value) => value?.isEmpty ?? true ? "Username cannot be empty" : null,
                        ),
                        const SizedBox(height: 8),
                        CheckboxListTile(
                            value: isApiKey.value, 
                            onChanged: (value) => isApiKey.value = value ?? false, 
                            title: const Text("Is API key")
                        ),
                        TextFormField(
                            decoration: InputDecoration(
                                labelText: isApiKey.value ? "API key" : "Password",
                                border: const OutlineInputBorder()
                            ),
                            onChanged: (value) => password.value = value,
                            validator: (value) => value?.isEmpty ?? true ? "Password cannot be empty" : null,
                        ),
                    ]),
                )),
                title: const Text("Add new account"),
                actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                    TextButton(onPressed: () {
                        if (formKey.currentState?.validate() ?? false) {
                            Navigator.pop(context, Account(booruId: booruId.value, username: username.value, password: password.value, isApiKey: isApiKey.value));
                        }
                    }, child: const Text("Add"))
                ]
            );

        return Scaffold(
            appBar: AppBar(
                title: const Text("Accounts"),
                actions: [
                    MaterialIconButton(icon: const Icon(Icons.add), onPressed: () async {
                        var account = await showDialog<Account?>(context: context, builder: (context) => makeLoginDialog(context));
                        if (account != null) {
                            accounts.value.add(account);
                            settings.accounts = accounts.value;
                        }
                    }),
                ],
            ),
            body: ListView.builder(
                itemCount: accounts.value.length, 
                itemBuilder: (context, index) {
                    return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        title: Text(accounts.value[index].username),
                        subtitle: Text(accounts.value[index].username),
                        leading: processIcon(settings.getBooruById(accounts.value[index].booruId)?.icon),
                        onTap: () async {
                            debugPrint("Clicked on account: $index");
                            username.value = accounts.value[index].username;
                            password.value = accounts.value[index].password;
                            booruId.value = accounts.value[index].booruId;
                            isApiKey.value = accounts.value[index].isApiKey;
                            var account = await showDialog<Account?>(context: context, builder: (context) => makeLoginDialog(context));
                            if (account != null) {
                                accounts.value[index] = account;
                                settings.accounts = accounts.value;
                            }
                        }
                    );
                }
            )
        ); 
        
        
    }
}