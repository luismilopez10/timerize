import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:timerize/models/shower_section.dart';
import 'package:timerize/providers/providers.dart';
import 'package:timerize/ui/input_decorations.dart';
import 'package:timerize/widgets/widgets.dart';

class NewSectionFormScreen extends StatelessWidget {
  static const String routerName = 'NewSection';
  final ShowerSection? showerSection;

  NewSectionFormScreen({
    super.key,
    this.showerSection,
  });

  final FocusNode minutesFocusNode = FocusNode();
  final FocusNode secondsFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final NewSectionFormProvider newSectionFormProvider =
        Provider.of<NewSectionFormProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            newSectionFormProvider.resetValues();
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Form(
          key: newSectionFormProvider.newSectionFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //* Formulario
              //* Título de Nueva sección/Editar sección
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  showerSection != null ? 'Editar sección' : 'Nueva sección',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10.0),

              //* Campo de Nombre de Sección
              TextFormField(
                controller: newSectionFormProvider.sectionNameController,
                autofocus: showerSection == null ? true : false,
                maxLength: 25,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => newSectionFormProvider.validate(
                    value!, 'Ingresa el nombre de la sección'),
                style: const TextStyle(
                  fontSize: 16.0,
                ),
                decoration: InputDecorations.authInputDecoration(
                  context,
                  hintText: '',
                  labelText: 'Nombre de la sección',
                  prefix: const Icon(Icons.calendar_view_month),
                ),
              ),
              const SizedBox(height: 20.0),

              //* Campo del Tiempo de la Sección
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: IncrementDecrement(
                      controller: newSectionFormProvider.minutesController,
                      minValue: 0,
                      maxValue: 200,
                      labelText: 'Minutos',
                      focusNode: minutesFocusNode,
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                      validator: (p0) {
                        final secondsAreEmptyOrZero = newSectionFormProvider
                                .secondsController.text.isEmpty ||
                            newSectionFormProvider.secondsController.text ==
                                '0';
                        final minutesAreEmptyOrZero = newSectionFormProvider
                                .minutesController.text.isEmpty ||
                            newSectionFormProvider.minutesController.text ==
                                '0';

                        if (secondsAreEmptyOrZero && minutesAreEmptyOrZero) {
                          return 'Ingresa el tiempo';
                        }

                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 20.0),
                  Expanded(
                    child: IncrementDecrement(
                      controller: newSectionFormProvider.secondsController,
                      minValue: 0,
                      maxValue: 59,
                      labelText: 'Segundos',
                      focusNode: secondsFocusNode,
                      validator: (p0) {
                        final secondsAreEmptyOrZero = newSectionFormProvider
                                .secondsController.text.isEmpty ||
                            newSectionFormProvider.secondsController.text ==
                                '0';
                        final minutesAreEmptyOrZero = newSectionFormProvider
                                .minutesController.text.isEmpty ||
                            newSectionFormProvider.minutesController.text ==
                                '0';

                        if (secondsAreEmptyOrZero && minutesAreEmptyOrZero) {
                          return '';
                        }

                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60.0),

              //* Botón de Continuar
              SizedBox(
                height: 50.0,
                child: MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0)),
                  color: Theme.of(context).primaryColor.withOpacity(0.9),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  onPressed: () {
                    if (newSectionFormProvider.isValidForm()) {
                      if (minutesFocusNode.hasFocus) minutesFocusNode.unfocus();
                      if (secondsFocusNode.hasFocus) secondsFocusNode.unfocus();

                      Future.delayed(const Duration(milliseconds: 20))
                          .then((value) {
                        newSectionFormProvider.saveShowerSection(
                            context, showerSection);

                        newSectionFormProvider.resetValues();

                        Navigator.pop(context);
                      });
                    }
                  },
                  child: Text(
                    showerSection != null ? 'Actualizar' : 'Guardar',
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
