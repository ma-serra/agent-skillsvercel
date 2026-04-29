#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/../templates"

DOC_TYPE="${1:-}"
LANG="${2:-pt-BR}"

cleanup() {
  rm -f /tmp/advogado-juridico-$$.tmp 2>/dev/null || true
}
trap cleanup EXIT

SUPPORTED_TYPES="nda service-contract employment privacy-policy terms-of-service lease partnership"

if [[ "$DOC_TYPE" == "--list" ]]; then
  echo '{"available_types":["nda","service-contract","employment","privacy-policy","terms-of-service","lease","partnership"],"languages":["pt-BR","en-US"]}' | python3 -m json.tool 2>/dev/null || \
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

if [[ "$LANG" != "pt-BR" && "$LANG" != "en-US" ]]; then
  echo "{\"error\":\"Unsupported language: $LANG. Use pt-BR or en-US.\"}" >&2
  exit 1
fi

echo "Loading template for $DOC_TYPE ($LANG)..." >&2

TEMPLATE_FILE="$TEMPLATES_DIR/${DOC_TYPE}-${LANG}.md"

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
    *)
      echo "Modelo genérico para [[TIPO_DOCUMENTO]]"
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
    *)
      echo "Generic template for [[DOCUMENT_TYPE]]"
      ;;
  esac
}

if [[ "$LANG" == "pt-BR" ]]; then
  case "$DOC_TYPE" in
    nda)           TITLE="Acordo de Confidencialidade (NDA)" ;;
    service-contract) TITLE="Contrato de Prestação de Serviços" ;;
    employment)    TITLE="Contrato de Trabalho" ;;
    privacy-policy) TITLE="Política de Privacidade (LGPD)" ;;
    terms-of-service) TITLE="Termos de Uso" ;;
    lease)         TITLE="Contrato de Locação" ;;
    partnership)   TITLE="Acordo de Parceria" ;;
  esac
  DISCLAIMER="Este documento é um modelo de referência. Consulte um advogado licenciado antes de assinar ou usar qualquer documento legal."
else
  case "$DOC_TYPE" in
    nda)           TITLE="Non-Disclosure Agreement (NDA)" ;;
    service-contract) TITLE="Service Agreement" ;;
    employment)    TITLE="Employment Contract" ;;
    privacy-policy) TITLE="Privacy Policy" ;;
    terms-of-service) TITLE="Terms of Service" ;;
    lease)         TITLE="Lease Agreement" ;;
    partnership)   TITLE="Partnership Agreement" ;;
  esac
  DISCLAIMER="This document is a reference template only. Consult a licensed attorney before signing or using any legal document."
fi

if [[ -n "$TEMPLATE_FILE" && -f "$TEMPLATE_FILE" ]]; then
  TEMPLATE_CONTENT=$(cat "$TEMPLATE_FILE")
else
  if [[ "$LANG" == "pt-BR" ]]; then
    TEMPLATE_CONTENT=$(get_template_ptbr "$DOC_TYPE")
  else
    TEMPLATE_CONTENT=$(get_template_enus "$DOC_TYPE")
  fi
fi

if [[ "$LANG" == "pt-BR" ]]; then
  PLACEHOLDERS=$(echo "$TEMPLATE_CONTENT" | grep -oE '\[\[[A-Z_]+\]\]' | sort -u | tr '\n' ',' | sed 's/,$//' || echo "")
else
  PLACEHOLDERS=$(echo "$TEMPLATE_CONTENT" | grep -oE '\[\[[A-Z_]+\]\]' | sort -u | tr '\n' ',' | sed 's/,$//' || echo "")
fi

python3 -c "
import json, sys
template = sys.stdin.read()
placeholders = [p.strip() for p in '''$PLACEHOLDERS'''.split(',') if p.strip()]
result = {
    'type': '$DOC_TYPE',
    'lang': '$LANG',
    'title': '$TITLE',
    'template': template,
    'placeholders': placeholders,
    'disclaimer': '$DISCLAIMER'
}
print(json.dumps(result, ensure_ascii=False, indent=2))
" <<< "$TEMPLATE_CONTENT"
