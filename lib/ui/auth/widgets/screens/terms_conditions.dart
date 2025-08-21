import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/ui/auth/view_model/terms_conditions_view_model.dart';
import 'package:minha_saude_frontend/ui/auth/widgets/layouts/login_form_layout.dart';

class TermsConditions extends StatelessWidget {
  final TermsConditionsViewModel viewModel;

  const TermsConditions({required this.viewModel, super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    const String tos = """
Neste Termo de Uso e Política de Privacidade, você encontrará informações sobre o funcionamento do serviço solicitado, fornecido por  meio de aplicações no site, sistemas e aplicativos para dispositivos  móveis e as regras aplicáveis a ele; o embasamento legal relacionado à  prestação do serviço; as suas responsabilidades ao utilizar o serviço;  as responsabilidades da administração pública ao fornecer o serviço;  informações para contato, caso exista alguma dúvida ou seja necessário  atualizar informações; e o foro responsável por eventuais reclamações,  caso questões deste documento tenham sido violadas.
Além disso, você encontrará informações sobre qual o tratamento dos dados pessoais realizados, de forma automatizada ou não, e a sua  finalidade; quais dados pessoais são necessários para a prestação do  serviço; a forma como eles são coletados; se há o compartilhamento dos  seus dados com terceiros; e quais as medidas de segurança implementadas  para proteger os seus dados.
O Termo de Uso e a Política de Privacidade na Receita Federal foram elaborados em conformidade com a Lei Federal nº 12.965, de 23 de abril de 2014 (Marco Civil da Internet), e com a Lei Federal nº 13.709, de 14 de agosto de 2018 (Lei Geral de Proteção de Dados Pessoais).
A Receita Federal se compromete a cumprir as normas previstas na Lei Geral de Proteção de Dados Pessoais (LGPD), e respeitar os princípios dispostos no art. 6º:
I - finalidade:  realização do tratamento para propósitos legítimos, específicos,  explícitos e informados ao titular, sem possibilidade de tratamento  posterior de forma incompatível com essas finalidades;
II - adequação: compatibilidade do tratamento com as finalidades informadas ao titular, de acordo com o contexto do tratamento;
III - necessidade:  limitação do tratamento ao mínimo necessário para a realização de suas  finalidades, com abrangência dos dados pertinentes, proporcionais e não  excessivos em relação às finalidades do tratamento de dados;
IV - livre acesso:  garantia, aos titulares, de consulta facilitada e gratuita sobre a forma e a duração do tratamento, bem como sobre a integralidade de seus dados pessoais;
V - qualidade dos dados: garantia, aos titulares, de exatidão, clareza, relevância e atualização dos dados, de acordo com a necessidade e para o cumprimento da  finalidade de seu tratamento;
VI - transparência:  garantia, aos titulares, de informações claras, precisas e facilmente  acessíveis sobre a realização do tratamento e os respectivos agentes de  tratamento, observados os segredos comercial e industrial;
VII - segurança:  utilização de medidas técnicas e administrativas aptas a proteger os  dados pessoais de acessos não autorizados e de situações acidentais ou  ilícitas de destruição, perda, alteração, comunicação ou difusão;
VIII - prevenção: adoção de medidas para prevenir a ocorrência de danos em virtude do tratamento de dados pessoais;
IX - não discriminação: impossibilidade de realização do tratamento para fins discriminatórios ilícitos ou abusivos;
X - responsabilização e prestação de contas: demonstração, pelo agente, da adoção de medidas eficazes e capazes de  comprovar a observância e o cumprimento das normas de proteção de dados  pessoais e, inclusive, da eficácia dessas medidas.
Aceitação do Termo de Uso e Política de Privacidade
Ao utilizar os serviços, você confirma  que leu, compreendeu o Termo de Uso e Política de Privacidade aplicáveis ao serviço solicitado e concorda em ficar a eles vinculado.
""";

    return LoginFormLayout(
      child: Padding(
        padding: EdgeInsetsGeometry.all(16),
        child: Column(
          spacing: 4,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Termos e Condições', style: theme.textTheme.titleLarge),
            const TextScroller(text: tos),
            FilledButton(
              onPressed: () {
                context.push("/register");
              },
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: Text('Li e concordo com os termos'),
            ),
          ],
        ),
      ),
    );
  }
}

class TextScroller extends StatelessWidget {
  const TextScroller({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: SingleChildScrollView(
          child: Text(text, style: theme.textTheme.bodyMedium),
        ),
      ),
    );
  }
}
