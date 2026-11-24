# Auditoria de Autenticação e Mitigação com Kali Linux e Medusa

Projeto prático desenvolvido durante o bootcamp de Cibersegurança da DIO para estudar o comportamento de serviços de rede (FTP, HTTP e SMB) diante de tentativas de autenticação automatizadas e propor medidas de proteção em ambiente isolado.

> **Nota:** Todos os testes deste repositório foram realizados exclusivamente entre máquinas virtuais locais no VirtualBox, isoladas da internet em rede *Host-Only* (`192.168.56.0/24`).

## Objetivos da Prática

- Montar um laboratório isolado no VirtualBox com Kali Linux e Metasploitable 2.
- Identificar serviços e portas ativas no alvo com Nmap.
- Simular testes de autenticação controlada em FTP, formulário web (DVWA) e SMB (*password spraying*).
- Documentar os resultados obtidos e as medidas de mitigação recomendadas para cada serviço.

## Topologia do Ambiente

| Máquina | Função | IP no Lab |
| :--- | :--- | :--- |
| **Kali Linux** | Estação de análise (Nmap 7.94SVN e Medusa v2.2) | `192.168.56.101` |
| **Metasploitable 2** | Alvo vulnerável (FTP, SMB e DVWA) | `192.168.56.102` |

## 1. Configuração da Rede Isolada

No VirtualBox, configurei uma rede exclusiva de hospedeiro (**Host-Only**) e mantive apenas esse adaptador ativo nas duas VMs, desabilitando interfaces NAT e Bridged para impedir qualquer tráfego externo.

Validação dos endereços IP em cada máquina:

```bash
# No Kali Linux
ip -br addr

# No Metasploitable 2
ifconfig
```

- **Evidências:** `images/01-ip-kali.jpg` e `images/02-ip-metasploitable.jpg`.

## 2. Mapeamento dos Serviços

Com a conectividade confirmada entre as VMs, executei o Nmap para verificar os serviços ativos nas portas alvo:

```bash
nmap -Pn -sV -p 21,80,139,445 192.168.56.102
```

Serviços identificados no alvo (`192.168.56.102`):
- **21/tcp:** FTP (`vsftpd 2.3.4`)
- **80/tcp:** HTTP (`Apache httpd 2.2.8` — hospedando o DVWA)
- **139/tcp e 445/tcp:** SMB / Samba (`3.0.20-Debian`)

- **Evidência:** `images/03-nmap-servicos.jpg`.

## 3. Wordlists de Laboratório

Para manter os testes rápidos e controlados, utilizei listas pequenas contendo apenas contas fictícias criadas para a prática:

- `wordlists/usuarios-lab.txt`
- `wordlists/senhas-lab.txt`

## 4. Cenários Executados

### 4.1. Serviço FTP (`21/tcp`)
- **Execução:** Teste de autenticação no serviço FTP utilizando o Medusa com thread única (`-t 1`):
  ```bash
  medusa -h 192.168.56.102 -U wordlists/usuarios-lab.txt -P wordlists/senhas-lab.txt -M ftp -t 1 -f -v 4
  ```
- **Resultado:** A conta de laboratório `ftp-lab` foi validada sem qualquer bloqueio por tentativas falhas consecutivas, trafegando os dados em texto claro.
- **Evidência:** `images/04-medusa-ftp.jpg`.

### 4.2. Formulário Web — DVWA (`80/tcp`)
- **Execução:** Análise do formulário de autenticação em `http://192.168.56.102/dvwa/login.php` com o nível de segurança configurado em **Low**.
- **Resultado:** No nível *Low*, a aplicação não aplica atraso (*delay*), bloqueio temporário ou desafio CAPTCHA após tentativas incorretas de login.

### 4.3. Serviço SMB — Password Spraying (`139/tcp` e `445/tcp`)
- **Execução:** Enumeração inicial dos compartilhamentos com `smbclient -L //192.168.56.102 -N`, seguida de teste de *password spraying* (uma única senha testada contra vários usuários locais):
  ```bash
  medusa -h 192.168.56.102 -U wordlists/usuarios-lab.txt -p 'Lab-Only-2026!' -M smbnt -t 1 -f -v 4
  ```
- **Resultado:** A validação da conta `lab-user-2` ocorreu sem disparar bloqueios por tentativas repetidas em um mesmo usuário.
- **Evidência:** `images/05-smb-spraying.jpg`.

## 5. Medidas de Mitigação e Hardening

- **FTP:** Substituir o FTP tradicional por **SFTP** ou **FTPS**, desabilitar login anônimo e configurar bloqueio automático de IP via **Fail2Ban**.
- **Aplicações Web:** Implementar *rate limiting*, atrasos progressivos após falhas de login, CAPTCHA e Autenticação Multifator (**MFA**).
- **SMB:** Desativar o protocolo legado **SMBv1**, exigir assinatura de pacotes (*SMB Signing*), restringir as portas `139` e `445` por firewall/VLAN e aplicar políticas de bloqueio de conta.
- **Monitoramento:** Centralizar logs de autenticação para alertar picos de falha de logon e remover contas de teste após o uso.

## 6. Estrutura do Repositório

```text
├── README.md
├── docs/
│   └── relatorio-resultados.md
├── images/
│   ├── 01-ip-kali.jpg
│   ├── 02-ip-metasploitable.jpg
│   ├── 03-nmap-servicos.jpg
│   ├── 04-medusa-ftp.jpg
│   └── 05-smb-spraying.jpg
└── wordlists/
    ├── usuarios-lab.txt
    └── senhas-lab.txt
```

O detalhamento completo da análise está registrado em [`docs/relatorio-resultados.md`](docs/relatorio-resultados.md).