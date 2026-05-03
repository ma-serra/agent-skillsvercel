#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/../templates"

DOC_TYPE="${1:-}"
export ADVOGADO_LANG="${2:-pt-BR}"

SUPPORTED_TYPES="nda service-contract employment privacy-policy terms-of-service lease partnership"

if [[ "$DOC_TYPE" == "--list" ]]; then
  echo '{"available_types":["nda","service-contract","employment","privacy-policy","terms-of-service","lease","partnership"],"languages":["pt-BR","en-US"]}'
  exit 0
fi

if [[ -z "$DOC_TYPE" ]]; then
  echo '{"error":"Missing document type. Run with --list to see available types."}' >&2
  exit 1
fi

if ! echo "$SUPPORTED_TYPES" | grep -qw "$DOC_TYPE"; then
  echo "{\"error\":\"Unknown document type: $DOC_TYPE. Run with --list to see supported types.\"}" >&2
  exit 1
fi

if [[ "$ADVOGADO_LANG" != "pt-BR" && "$ADVOGADO_LANG" != "en-US" ]]; then
  echo "{\"error\":\"Unsupported language: $ADVOGADO_LANG. Use pt-BR or en-US.\"}" >&2
  exit 1
fi

echo "Loading template for $DOC_TYPE ($ADVOGADO_LANG)..." >&2

TEMPLATE_FILE="$TEMPLATES_DIR/${DOC_TYPE}-${ADVOGADO_LANG}.md"

if [[ ! -f "$TEMPLATE_FILE" ]]; then
  echo "Template file not found at $TEMPLATE_FILE, using built-in fallback..." >&2
  TEMPLATE_FILE=""
fi

get_template_ptbr() {
  local type="$1"
  case "$type" in
    nda)
      cat <<'TMPL'
# ACORDO DE CONFIDENCIALIDADE E NÃO DIVULGAÇÃO

**PARTES:**

**PARTE DIVULGADORA:** [[NOME_PARTE_A]], inscrita no CNPJ/CPF sob nº [[CNPJ_CPF_A]], com sede em [[ENDERECO_A]] ("Parte Divulgadora").

**PARTE RECEPTORA:** [[NOME_PARTE_B]], inscrita no CNPJ/CPF sob nº [[CNPJ_CPF_B]], com sede em [[ENDERECO_B]] ("Parte Receptora").

**OBJETO:** As partes desejam explorar uma possível relação comercial relacionada a [[OBJETO_NEGOCIO]], sendo necessário o compartilhamento de informações confidenciais.

**1. INFORMAÇÕES CONFIDENCIAIS**
Consideram-se confidenciais todas as informações técnicas, comerciais, financeiras, operacionais e estratégicas divulgadas pela Parte Divulgadora, incluindo, mas não se limitando a: [[LISTA_INFORMACOES]].

**2. OBRIGAÇÕES DA PARTE RECEPTORA**
A Parte Receptora se compromete a: (i) manter sigilo absoluto; (ii) utilizar as informações somente para a finalidade acordada; (iii) não reproduzir, copiar ou divulgar a terceiros sem autorização prévia e por escrito.

**3. EXCEÇÕES**
Não são consideradas confidenciais as informações que: (i) sejam de domínio público; (ii) já eram de conhecimento prévio da Parte Receptora; (iii) sejam divulgadas por determinação judicial ou legal.

**4. VIGÊNCIA**
Este Acordo entra em vigor na data de sua assinatura e permanecerá válido por [[PRAZO_VIGENCIA]] anos, podendo ser renovado por mútuo acordo.

**5. PENALIDADES**
O descumprimento deste Acordo sujeitará a Parte infratora ao pagamento de multa no valor de R$ [[VALOR_MULTA]], além de perdas e danos apurados judicialmente.

**6. FORO**
Fica eleito o foro da Comarca de [[CIDADE_FORO]], [[ESTADO_FORO]], para dirimir quaisquer controvérsias.

[[CIDADE]], [[DATA]]

_____________________________          _____________________________
[[NOME_PARTE_A]]                       [[NOME_PARTE_B]]
[[CARGO_A]]                            [[CARGO_B]]

Testemunhas:
1. _________________________ CPF: _____________
2. _________________________ CPF: _____________
TMPL
      ;;
    service-contract)
      cat <<'TMPL'
# CONTRATO DE PRESTAÇÃO DE SERVIÇOS

**CONTRATANTE:** [[NOME_CONTRATANTE]], inscrito(a) no CNPJ/CPF sob nº [[CNPJ_CPF_CONTRATANTE]], com sede/domicílio em [[ENDERECO_CONTRATANTE]].

**CONTRATADO:** [[NOME_CONTRATADO]], inscrito(a) no CNPJ/CPF sob nº [[CNPJ_CPF_CONTRATADO]], com sede/domicílio em [[ENDERECO_CONTRATADO]].

**1. OBJETO**
O CONTRATADO prestará ao CONTRATANTE os seguintes serviços: [[DESCRICAO_SERVICOS]].

**2. PRAZO**
Os serviços serão executados no período de [[DATA_INICIO]] a [[DATA_FIM]], podendo ser prorrogado mediante aditivo escrito.

**3. REMUNERAÇÃO**
Pelos serviços prestados, o CONTRATANTE pagará ao CONTRATADO o valor de R$ [[VALOR_TOTAL]] ([[VALOR_POR_EXTENSO]]), conforme cronograma: [[CRONOGRAMA_PAGAMENTOS]].

**4. OBRIGAÇÕES DO CONTRATADO**
O CONTRATADO obriga-se a: (i) executar os serviços com qualidade e nos prazos ajustados; (ii) manter sigilo sobre informações do CONTRATANTE; (iii) arcar com todos os encargos trabalhistas e tributários de sua responsabilidade.

**5. OBRIGAÇÕES DO CONTRATANTE**
O CONTRATANTE obriga-se a: (i) efetuar os pagamentos nas datas acordadas; (ii) fornecer as informações necessárias à execução dos serviços; (iii) não reter pagamentos sem justificativa formal.

**6. RESCISÃO**
Qualquer das partes poderá rescindir este contrato mediante aviso prévio de [[PRAZO_AVISO_PREVIO]] dias, por escrito.

**7. FORO**
Fica eleito o foro de [[CIDADE_FORO]] para dirimir eventuais litígios.

[[CIDADE]], [[DATA]]

_____________________________          _____________________________
CONTRATANTE                            CONTRATADO
TMPL
      ;;
    employment)
      cat <<'TMPL'
# CONTRATO DE TRABALHO

**EMPREGADOR:** [[NOME_EMPREGADOR]], inscrito(a) no CNPJ sob nº [[CNPJ_EMPREGADOR]], com sede em [[ENDERECO_EMPREGADOR]].

**EMPREGADO:** [[NOME_EMPREGADO]], portador(a) do CPF nº [[CPF_EMPREGADO]], residente em [[ENDERECO_EMPREGADO]].

**1. CARGO E FUNÇÃO**
O EMPREGADO é contratado para exercer a função de [[CARGO]], sob as ordens e supervisão do EMPREGADOR.

**2. JORNADA DE TRABALHO**
A jornada de trabalho será de [[HORAS_DIARIAS]] horas diárias e [[HORAS_SEMANAIS]] horas semanais, nos horários de [[HORARIO_INICIO]] às [[HORARIO_FIM]], de [[DIAS_SEMANA]].

**3. REMUNERAÇÃO**
O EMPREGADO receberá salário mensal de R$ [[SALARIO]] ([[SALARIO_POR_EXTENSO]]), pagos até o [[DIA_PAGAMENTO]]º dia útil do mês subsequente.

**4. BENEFÍCIOS**
O EMPREGADO terá direito a: [[LISTA_BENEFICIOS]] (vale-transporte, vale-refeição, plano de saúde, conforme política da empresa).

**5. PRAZO**
O presente contrato é por prazo [[DETERMINADO_INDETERMINADO]], com início em [[DATA_INICIO]][[, e término previsto em [[DATA_FIM]]]].

**6. FÉRIAS E 13º SALÁRIO**
O EMPREGADO terá direito a férias anuais de 30 dias e 13º salário, conforme a Consolidação das Leis do Trabalho (CLT).

**7. RESCISÃO**
O contrato poderá ser rescindido por qualquer das partes, mediante aviso prévio de 30 dias, ou indenização equivalente, conforme a CLT.

**8. CONFIDENCIALIDADE**
O EMPREGADO compromete-se a manter sigilo sobre informações confidenciais do EMPREGADOR durante e após a vigência do contrato.

[[CIDADE]], [[DATA]]

_____________________________          _____________________________
EMPREGADOR                             EMPREGADO
TMPL
      ;;
    privacy-policy)
      cat <<'TMPL'
# POLÍTICA DE PRIVACIDADE

**Última atualização:** [[DATA_ATUALIZACAO]]

**[[NOME_EMPRESA]]** ("nós", "nosso") está comprometida com a proteção dos seus dados pessoais, em conformidade com a Lei Geral de Proteção de Dados (LGPD — Lei nº 13.709/2018).

**1. DADOS COLETADOS**
Coletamos os seguintes dados pessoais: [[LISTA_DADOS]].

**2. FINALIDADE DO TRATAMENTO**
Seus dados são tratados para: [[FINALIDADES]].

**3. BASE LEGAL**
O tratamento é realizado com base em: [[BASE_LEGAL]] (Art. [[ARTIGO_LGPD]], LGPD).

**4. COMPARTILHAMENTO**
Seus dados poderão ser compartilhados com: [[TERCEIROS]], sempre com as salvaguardas adequadas.

**5. RETENÇÃO**
Mantemos seus dados pelo período de [[PRAZO_RETENCAO]], salvo obrigação legal diversa.

**6. SEUS DIREITOS (Art. 18, LGPD)**
Você tem direito a: confirmação, acesso, correção, anonimização, portabilidade, eliminação, informação e revogação do consentimento.

**7. CONTATO — DPO**
Encarregado de Dados (DPO): [[NOME_DPO]] — [[EMAIL_DPO]]

**8. ALTERAÇÕES**
Esta política pode ser atualizada a qualquer momento. A versão vigente estará sempre disponível em [[URL_POLITICA]].
TMPL
      ;;
    terms-of-service)
      cat <<'TMPL'
# TERMOS DE USO

**Última atualização:** [[DATA_ATUALIZACAO]]

**[[NOME_EMPRESA]]** ("nós", "empresa") disponibiliza os seguintes serviços: [[DESCRICAO_SERVICOS]] ("Serviços"). Ao utilizar nossos Serviços, você concorda com estes Termos.

**1. ACEITAÇÃO**
O uso dos Serviços implica aceitação integral destes Termos. Se você não concordar, não utilize os Serviços.

**2. ELEGIBILIDADE**
Para utilizar os Serviços, você deve ter pelo menos [[IDADE_MINIMA]] anos e capacidade legal para celebrar contratos.

**3. CONTA DO USUÁRIO**
Você é responsável pela confidencialidade de suas credenciais e por todas as atividades realizadas em sua conta.

**4. USO PERMITIDO**
Você concorda em utilizar os Serviços apenas para fins lícitos e de acordo com estes Termos. É vedado: [[LISTA_PROIBICOES]].

**5. PROPRIEDADE INTELECTUAL**
Todo o conteúdo disponibilizado nos Serviços é de propriedade da [[NOME_EMPRESA]] ou de seus licenciantes, protegido por lei.

**6. LIMITAÇÃO DE RESPONSABILIDADE**
Nossa responsabilidade total perante você não excederá R$ [[VALOR_LIMITE]] ou o valor pago pelos Serviços nos últimos [[PERIODO]] meses.

**7. RESCISÃO**
Reservamo-nos o direito de suspender ou encerrar sua conta em caso de violação destes Termos.

**8. ALTERAÇÕES**
Podemos atualizar estes Termos a qualquer momento. Notificaremos via [[MEIO_NOTIFICACAO]] com [[PRAZO_AVISO]] dias de antecedência.

**9. FORO**
Fica eleito o foro de [[CIDADE_FORO]] para dirimir quaisquer controvérsias.

Contato: [[EMAIL_CONTATO]]
TMPL
      ;;
    lease)
      cat <<'TMPL'
# CONTRATO DE LOCAÇÃO

**LOCADOR:** [[NOME_LOCADOR]], portador(a) do CPF/CNPJ nº [[CPF_CNPJ_LOCADOR]], com endereço em [[ENDERECO_LOCADOR]] ("Locador").

**LOCATÁRIO:** [[NOME_LOCATARIO]], portador(a) do CPF/CNPJ nº [[CPF_CNPJ_LOCATARIO]], com endereço em [[ENDERECO_LOCATARIO]] ("Locatário").

**IMÓVEL:** [[DESCRICAO_IMOVEL]], situado à [[ENDERECO_IMOVEL]], registrado sob matrícula nº [[MATRICULA_IMOVEL]] no Cartório de Registro de Imóveis de [[CIDADE_CARTORIO]].

**1. OBJETO**
O LOCADOR cede ao LOCATÁRIO, para uso [[RESIDENCIAL_COMERCIAL]], o imóvel descrito acima.

**2. PRAZO**
O presente contrato tem duração de [[PRAZO_MESES]] meses, com início em [[DATA_INICIO]] e término em [[DATA_FIM]], podendo ser renovado.

**3. ALUGUEL**
O aluguel mensal é de R$ [[VALOR_ALUGUEL]] ([[VALOR_POR_EXTENSO]]), com vencimento no dia [[DIA_VENCIMENTO]] de cada mês, a ser pago via [[FORMA_PAGAMENTO]].

**4. REAJUSTE**
O aluguel será reajustado anualmente pelo índice [[INDICE_REAJUSTE]] (IGP-M, IPCA ou outro).

**5. ENCARGOS**
Ficam a cargo do LOCATÁRIO: IPTU, condomínio, água, luz e demais taxas de consumo. A cargo do LOCADOR: [[ENCARGOS_LOCADOR]].

**6. GARANTIA LOCATÍCIA**
Como garantia, o LOCATÁRIO oferece: [[TIPO_GARANTIA]] (caução, fiador, seguro-fiança ou título de capitalização).

**7. BENFEITORIAS**
Benfeitorias realizadas pelo LOCATÁRIO [[serão_nao_serao]] indenizadas, salvo acordo prévio por escrito.

**8. RESCISÃO ANTECIPADA**
Em caso de rescisão antecipada pelo LOCATÁRIO, será devida multa equivalente a [[PERCENTUAL_MULTA]]% do valor residual do contrato.

**9. FORO**
Fica eleito o foro da Comarca de [[CIDADE_FORO]] para dirimir quaisquer litígios.

[[CIDADE]], [[DATA]]

_____________________________          _____________________________
LOCADOR                                LOCATÁRIO
TMPL
      ;;
    partnership)
      cat <<'TMPL'
# ACORDO DE PARCERIA COMERCIAL

**PARCEIRO A:** [[NOME_PARCEIRO_A]], inscrito(a) no CNPJ/CPF sob nº [[CNPJ_CPF_A]], com sede em [[ENDERECO_A]] ("Parceiro A").

**PARCEIRO B:** [[NOME_PARCEIRO_B]], inscrito(a) no CNPJ/CPF sob nº [[CNPJ_CPF_B]], com sede em [[ENDERECO_B]] ("Parceiro B").

**1. OBJETO**
As partes celebram o presente Acordo com o objetivo de [[DESCRICAO_PARCERIA]], nos termos e condições aqui estabelecidos.

**2. OBRIGAÇÕES DO PARCEIRO A**
O Parceiro A obriga-se a: [[OBRIGACOES_PARCEIRO_A]].

**3. OBRIGAÇÕES DO PARCEIRO B**
O Parceiro B obriga-se a: [[OBRIGACOES_PARCEIRO_B]].

**4. PARTICIPAÇÃO NOS RESULTADOS**
Os resultados da parceria serão divididos na proporção de [[PERCENTUAL_A]]% para o Parceiro A e [[PERCENTUAL_B]]% para o Parceiro B.

**5. PRAZO**
Este Acordo vigorará por [[PRAZO_VIGENCIA]], com início em [[DATA_INICIO]], podendo ser renovado por mútuo acordo.

**6. EXCLUSIVIDADE**
[[A parceria é/não é]] exclusiva no segmento de [[SEGMENTO]] para a região de [[REGIAO]].

**7. CONFIDENCIALIDADE**
As partes comprometem-se a manter sigilo sobre informações confidenciais trocadas no âmbito desta parceria.

**8. RESCISÃO**
Qualquer das partes poderá rescindir este Acordo mediante aviso prévio de [[PRAZO_AVISO_PREVIO]] dias, por escrito.

**9. FORO**
Fica eleito o foro de [[CIDADE_FORO]] para dirimir quaisquer controvérsias.

[[CIDADE]], [[DATA]]

_____________________________          _____________________________
PARCEIRO A                             PARCEIRO B
TMPL
      ;;
  esac
}

get_template_enus() {
  local type="$1"
  case "$type" in
    nda)
      cat <<'TMPL'
# NON-DISCLOSURE AGREEMENT (NDA)

**PARTIES:**

**DISCLOSING PARTY:** [[PARTY_A_NAME]], a [[PARTY_A_ENTITY_TYPE]] organized under the laws of [[PARTY_A_JURISDICTION]], with its principal place of business at [[PARTY_A_ADDRESS]] ("Disclosing Party").

**RECEIVING PARTY:** [[PARTY_B_NAME]], a [[PARTY_B_ENTITY_TYPE]] organized under the laws of [[PARTY_B_JURISDICTION]], with its principal place of business at [[PARTY_B_ADDRESS]] ("Receiving Party").

**PURPOSE:** The parties wish to explore a potential business relationship regarding [[BUSINESS_PURPOSE]] and may need to share certain confidential information.

**1. CONFIDENTIAL INFORMATION**
"Confidential Information" means any non-public information disclosed by the Disclosing Party, including but not limited to: [[LIST_OF_INFORMATION]].

**2. OBLIGATIONS**
Receiving Party agrees to: (i) hold all Confidential Information in strict confidence; (ii) use it solely for the Purpose; (iii) not disclose it to any third party without prior written consent.

**3. EXCEPTIONS**
Obligations do not apply to information that: (i) is or becomes publicly known through no breach; (ii) was rightfully known before disclosure; (iii) is required to be disclosed by law or court order.

**4. TERM**
This Agreement is effective as of [[EFFECTIVE_DATE]] and remains in force for [[TERM_YEARS]] years.

**5. REMEDIES**
A breach may cause irreparable harm. The Disclosing Party shall be entitled to seek equitable relief, including injunction, in addition to all other remedies.

**6. GOVERNING LAW**
This Agreement shall be governed by the laws of [[GOVERNING_STATE]], without regard to conflict of law principles.

Signed as of [[DATE]]:

_____________________________          _____________________________
[[PARTY_A_NAME]]                       [[PARTY_B_NAME]]
[[PARTY_A_SIGNATORY_TITLE]]            [[PARTY_B_SIGNATORY_TITLE]]
TMPL
      ;;
    service-contract)
      cat <<'TMPL'
# SERVICE AGREEMENT

**CLIENT:** [[CLIENT_NAME]], a [[CLIENT_ENTITY_TYPE]] with its principal place of business at [[CLIENT_ADDRESS]] ("Client").

**SERVICE PROVIDER:** [[PROVIDER_NAME]], a [[PROVIDER_ENTITY_TYPE]] with its principal place of business at [[PROVIDER_ADDRESS]] ("Provider").

**1. SERVICES**
Provider shall perform the following services for Client: [[DESCRIPTION_OF_SERVICES]] ("Services").

**2. TERM**
This Agreement commences on [[START_DATE]] and continues until [[END_DATE]], unless earlier terminated.

**3. COMPENSATION**
Client shall pay Provider [[PAYMENT_AMOUNT]] ([[PAYMENT_SCHEDULE]]). Invoices are due within [[PAYMENT_TERMS]] days of receipt.

**4. INDEPENDENT CONTRACTOR**
Provider is an independent contractor. Nothing herein creates an employment, partnership, or joint venture relationship.

**5. INTELLECTUAL PROPERTY**
All work product created under this Agreement shall be [[IP_OWNERSHIP_TERMS]].

**6. CONFIDENTIALITY**
Provider agrees to keep all Client information confidential and not to disclose it to third parties.

**7. TERMINATION**
Either party may terminate this Agreement upon [[NOTICE_PERIOD]] days written notice.

**8. LIMITATION OF LIABILITY**
Provider's liability shall not exceed the fees paid in the [[LIABILITY_PERIOD]] preceding the claim.

**9. GOVERNING LAW**
This Agreement is governed by the laws of [[GOVERNING_STATE]].

Signed as of [[DATE]]:

_____________________________          _____________________________
CLIENT                                 SERVICE PROVIDER
TMPL
      ;;
    employment)
      cat <<'TMPL'
# EMPLOYMENT AGREEMENT

**EMPLOYER:** [[EMPLOYER_NAME]], a [[EMPLOYER_ENTITY_TYPE]] with its principal place of business at [[EMPLOYER_ADDRESS]] ("Employer").

**EMPLOYEE:** [[EMPLOYEE_NAME]], residing at [[EMPLOYEE_ADDRESS]] ("Employee").

**1. POSITION AND DUTIES**
Employer agrees to employ Employee in the position of [[JOB_TITLE]]. Employee shall perform duties including: [[JOB_DUTIES]].

**2. START DATE AND TERM**
Employment commences on [[START_DATE]] and is [[AT_WILL_OR_FIXED_TERM]].

**3. COMPENSATION**
Employee shall receive a base salary of [[SALARY_AMOUNT]] per [[PAY_PERIOD]], payable on [[PAY_DATE]].

**4. BENEFITS**
Employee is eligible for the following benefits: [[BENEFITS_LIST]].

**5. WORKING HOURS**
Normal working hours are [[HOURS_PER_WEEK]] hours per week, [[SCHEDULE_DETAILS]].

**6. CONFIDENTIALITY AND IP**
Employee agrees to maintain the confidentiality of Employer's proprietary information and assigns all work product to Employer.

**7. NON-COMPETE / NON-SOLICITATION**
For [[RESTRICTION_PERIOD]] following termination, Employee agrees to [[NON_COMPETE_TERMS]].

**8. TERMINATION**
Either party may terminate this Agreement upon [[NOTICE_PERIOD]] days written notice. Employer may terminate for cause immediately.

**9. GOVERNING LAW**
This Agreement is governed by the laws of [[GOVERNING_STATE]].

Signed as of [[DATE]]:

_____________________________          _____________________________
EMPLOYER                               EMPLOYEE
TMPL
      ;;
    privacy-policy)
      cat <<'TMPL'
# PRIVACY POLICY

**Last Updated:** [[LAST_UPDATED]]

**[[COMPANY_NAME]]** ("we," "us," "our") is committed to protecting your personal information in accordance with applicable privacy laws, including GDPR and CCPA where applicable.

**1. INFORMATION WE COLLECT**
We collect: [[LIST_OF_DATA_COLLECTED]].

**2. HOW WE USE YOUR INFORMATION**
We use your information to: [[LIST_OF_PURPOSES]].

**3. LEGAL BASIS (GDPR)**
We process your data on the basis of: [[LEGAL_BASIS]].

**4. SHARING YOUR INFORMATION**
We may share your information with: [[THIRD_PARTIES]], under appropriate data protection agreements.

**5. DATA RETENTION**
We retain your data for [[RETENTION_PERIOD]], unless a longer retention is required by law.

**6. YOUR RIGHTS**
Depending on your location, you may have the right to access, correct, delete, restrict, or port your data, and to object to processing.

**7. CONTACT — DPO / PRIVACY CONTACT**
Privacy inquiries: [[PRIVACY_CONTACT_NAME]] — [[PRIVACY_CONTACT_EMAIL]]

**8. CHANGES**
We may update this policy at any time. The current version is always available at [[POLICY_URL]].
TMPL
      ;;
    terms-of-service)
      cat <<'TMPL'
# TERMS OF SERVICE

**Last Updated:** [[LAST_UPDATED]]

**[[COMPANY_NAME]]** ("we," "us," "our") provides the following services: [[DESCRIPTION_OF_SERVICES]] ("Services"). By using our Services, you agree to these Terms.

**1. ACCEPTANCE**
By accessing or using the Services, you agree to be bound by these Terms. If you disagree, do not use the Services.

**2. ELIGIBILITY**
You must be at least [[MINIMUM_AGE]] years old and legally capable of entering into contracts to use the Services.

**3. USER ACCOUNTS**
You are responsible for maintaining the confidentiality of your credentials and for all activities under your account.

**4. PERMITTED USE**
You agree to use the Services only for lawful purposes. You must not: [[LIST_OF_PROHIBITIONS]].

**5. INTELLECTUAL PROPERTY**
All content provided through the Services is owned by [[COMPANY_NAME]] or its licensors and is protected by applicable law.

**6. LIMITATION OF LIABILITY**
Our total liability to you shall not exceed [[LIABILITY_CAP]] or the amounts paid by you for the Services in the past [[LIABILITY_PERIOD]] months.

**7. TERMINATION**
We reserve the right to suspend or terminate your account for violation of these Terms.

**8. CHANGES**
We may update these Terms at any time. We will notify you via [[NOTIFICATION_METHOD]] at least [[NOTICE_DAYS]] days in advance.

**9. GOVERNING LAW**
These Terms are governed by the laws of [[GOVERNING_STATE]].

Contact: [[CONTACT_EMAIL]]
TMPL
      ;;
    lease)
      cat <<'TMPL'
# LEASE AGREEMENT

**LANDLORD:** [[LANDLORD_NAME]], with an address at [[LANDLORD_ADDRESS]] ("Landlord").

**TENANT:** [[TENANT_NAME]], with an address at [[TENANT_ADDRESS]] ("Tenant").

**PREMISES:** [[PROPERTY_DESCRIPTION]], located at [[PROPERTY_ADDRESS]] ("Premises").

**1. LEASE TERM**
This Lease commences on [[START_DATE]] and expires on [[END_DATE]], unless sooner terminated.

**2. RENT**
Tenant agrees to pay Landlord [[MONTHLY_RENT]] per month, due on the [[DUE_DAY]]th day of each month, payable to [[PAYMENT_METHOD]].

**3. SECURITY DEPOSIT**
Tenant shall pay a security deposit of [[SECURITY_DEPOSIT_AMOUNT]], to be returned within [[RETURN_DAYS]] days of lease termination, less any deductions for damages.

**4. USE OF PREMISES**
Tenant shall use the Premises solely for [[RESIDENTIAL_COMMERCIAL]] purposes and shall not sublet without Landlord's prior written consent.

**5. UTILITIES AND MAINTENANCE**
Tenant is responsible for: [[TENANT_UTILITIES]]. Landlord is responsible for: [[LANDLORD_RESPONSIBILITIES]].

**6. ALTERATIONS**
Tenant shall not make alterations without Landlord's prior written consent. All approved alterations become Landlord's property upon termination.

**7. EARLY TERMINATION**
If Tenant terminates this Lease early, Tenant shall pay a penalty of [[EARLY_TERMINATION_FEE]].

**8. GOVERNING LAW**
This Lease is governed by the laws of [[GOVERNING_STATE]].

Signed as of [[DATE]]:

_____________________________          _____________________________
LANDLORD                               TENANT
TMPL
      ;;
    partnership)
      cat <<'TMPL'
# PARTNERSHIP AGREEMENT

**PARTNER A:** [[PARTNER_A_NAME]], a [[PARTNER_A_ENTITY_TYPE]] with its principal place of business at [[PARTNER_A_ADDRESS]] ("Partner A").

**PARTNER B:** [[PARTNER_B_NAME]], a [[PARTNER_B_ENTITY_TYPE]] with its principal place of business at [[PARTNER_B_ADDRESS]] ("Partner B").

**1. PURPOSE**
The parties enter this Agreement to [[PARTNERSHIP_PURPOSE]], on the terms set forth herein.

**2. OBLIGATIONS OF PARTNER A**
Partner A agrees to: [[PARTNER_A_OBLIGATIONS]].

**3. OBLIGATIONS OF PARTNER B**
Partner B agrees to: [[PARTNER_B_OBLIGATIONS]].

**4. PROFIT AND LOSS SHARING**
Profits and losses shall be shared as follows: Partner A: [[PARTNER_A_SHARE]]%; Partner B: [[PARTNER_B_SHARE]]%.

**5. TERM**
This Agreement commences on [[START_DATE]] and continues for [[TERM_LENGTH]], unless earlier terminated.

**6. EXCLUSIVITY**
This partnership [[IS_NOT_EXCLUSIVE]] in the [[MARKET_SEGMENT]] segment within [[TERRITORY]].

**7. CONFIDENTIALITY**
Each party shall keep the other's confidential information strictly confidential during and after the term of this Agreement.

**8. TERMINATION**
Either party may terminate this Agreement upon [[NOTICE_PERIOD]] days written notice.

**9. GOVERNING LAW**
This Agreement is governed by the laws of [[GOVERNING_STATE]].

Signed as of [[DATE]]:

_____________________________          _____________________________
PARTNER A                              PARTNER B
TMPL
      ;;
  esac
}

if [[ "$ADVOGADO_LANG" == "pt-BR" ]]; then
  case "$DOC_TYPE" in
    nda)           export ADVOGADO_TITLE="Acordo de Confidencialidade (NDA)" ;;
    service-contract) export ADVOGADO_TITLE="Contrato de Prestação de Serviços" ;;
    employment)    export ADVOGADO_TITLE="Contrato de Trabalho" ;;
    privacy-policy) export ADVOGADO_TITLE="Política de Privacidade (LGPD)" ;;
    terms-of-service) export ADVOGADO_TITLE="Termos de Uso" ;;
    lease)         export ADVOGADO_TITLE="Contrato de Locação" ;;
    partnership)   export ADVOGADO_TITLE="Acordo de Parceria" ;;
  esac
  export ADVOGADO_DISCLAIMER="Este documento é um modelo de referência. Consulte um advogado licenciado antes de assinar ou usar qualquer documento legal."
else
  case "$DOC_TYPE" in
    nda)           export ADVOGADO_TITLE="Non-Disclosure Agreement (NDA)" ;;
    service-contract) export ADVOGADO_TITLE="Service Agreement" ;;
    employment)    export ADVOGADO_TITLE="Employment Agreement" ;;
    privacy-policy) export ADVOGADO_TITLE="Privacy Policy" ;;
    terms-of-service) export ADVOGADO_TITLE="Terms of Service" ;;
    lease)         export ADVOGADO_TITLE="Lease Agreement" ;;
    partnership)   export ADVOGADO_TITLE="Partnership Agreement" ;;
  esac
  export ADVOGADO_DISCLAIMER="This document is a reference template only. Consult a licensed attorney before signing or using any legal document."
fi

TMP_TEMPLATE=$(mktemp /tmp/advogado-template-XXXXXX.tmp)
cleanup() { rm -f "$TMP_TEMPLATE" 2>/dev/null || true; }
trap cleanup EXIT

if [[ -n "$TEMPLATE_FILE" && -f "$TEMPLATE_FILE" ]]; then
  cat "$TEMPLATE_FILE" > "$TMP_TEMPLATE"
else
  if [[ "$ADVOGADO_LANG" == "pt-BR" ]]; then
    get_template_ptbr "$DOC_TYPE" > "$TMP_TEMPLATE"
  else
    get_template_enus "$DOC_TYPE" > "$TMP_TEMPLATE"
  fi
fi

export ADVOGADO_TEMPLATE_FILE="$TMP_TEMPLATE"
export ADVOGADO_DOC_TYPE="$DOC_TYPE"

python3 <<'PYEOF'
import json, os, re

doc_type = os.environ['ADVOGADO_DOC_TYPE']
lang = os.environ['ADVOGADO_LANG']
title = os.environ['ADVOGADO_TITLE']
disclaimer = os.environ['ADVOGADO_DISCLAIMER']

with open(os.environ['ADVOGADO_TEMPLATE_FILE'], encoding='utf-8') as f:
    template = f.read()

placeholders = sorted(set(re.findall(r'\[\[[A-Z_]+\]\]', template)))

result = {
    'type': doc_type,
    'lang': lang,
    'title': title,
    'template': template,
    'placeholders': placeholders,
    'disclaimer': disclaimer
}
print(json.dumps(result, ensure_ascii=False, indent=2))
PYEOF
