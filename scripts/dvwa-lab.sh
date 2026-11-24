#!/usr/bin/env bash
set -euo pipefail

# Uso didático: este script apenas valida parâmetros e mostra o roteiro.
# Não automatize login em alvos fora do laboratório.
: "${LAB_AUTHORIZED:?Defina LAB_AUTHORIZED=yes após confirmar a autorização}"
if [[ "$LAB_AUTHORIZED" != "yes" ]]; then
  echo "Abortado: LAB_AUTHORIZED precisa ser exatamente yes" >&2
  exit 1
fi
: "${DVWA_IP:?Defina DVWA_IP com o IP privado da VM DVWA}"
if [[ ! "$DVWA_IP" =~ ^(10\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[0-1])\.) ]]; then
  echo "Abortado: o alvo precisa estar em uma faixa IPv4 privada" >&2
  exit 1
fi

BASE_URL="${BASE_URL:-http://${DVWA_IP}/dvwa/login.php}"
MAX_ATTEMPTS="${MAX_ATTEMPTS:-3}"
if ! [[ "$MAX_ATTEMPTS" =~ ^[1-3]$ ]]; then
  echo "Abortado: MAX_ATTEMPTS deve ser entre 1 e 3" >&2
  exit 1
fi

echo "Alvo privado validado: $BASE_URL"
echo "Limite de tentativas configurado: $MAX_ATTEMPTS"
echo "Próximo passo: faça as tentativas manualmente ou adapte o fluxo à versão do DVWA."
echo "Não informe credenciais neste script e não grave cookies/tokens nas evidências."
