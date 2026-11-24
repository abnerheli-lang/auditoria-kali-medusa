# Relatório de Resultados — Auditoria Controlada com Kali Linux e Medusa

> **Nota de ambiente:** Todos os testes descritos neste relatório foram executados exclusivamente em laboratório local no VirtualBox, utilizando rede isolada (*Host-Only*) sem acesso à Internet.

## Identificação

- **Autor:** Abner Riboli
- **Desafio:** Criando um Ataque Brute Force de Senhas com Medusa e Kali Linux (Bootcamp DIO)
- **Data:** 23/11/2026

## Ambiente do Laboratório

O laboratório foi configurado no VirtualBox com duas máquinas virtuais conectadas a uma rede exclusiva de hospedeiro (**Host-Only** — `192.168.56.0/24`), com adaptadores NAT e Bridged desativados:

- **Kali Linux (`192.168.56.101`):** Estação de análise (Nmap 7.94SVN, Medusa v2.2 e smbclient)
- **Metasploitable 2 (`192.168.56.102`):** Alvo vulnerável hospedando FTP (`vsftpd 2.3.4`), SMB (`Samba 3.0.20-Debian`) e HTTP (`Apache httpd 2.2.8` / DVWA)

Para manter os testes controlados, utilizei wordlists reduzidas criadas especificamente para contas de teste do laboratório, limitando a execução a uma única thread (`-t 1`).

## Evidências Visuais

As capturas de tela registradas durante a execução estão salvas na pasta `images/`:

- `01-ip-kali.jpg`: saída de `ip -br addr` no Kali Linux (`192.168.56.101`);
- `02-ip-metasploitable.jpg`: saída de `ifconfig` no Metasploitable 2 (`192.168.56.102`);
- `03-nmap-servicos.jpg`: mapeamento de portas e serviços ativos com Nmap;
- `04-medusa-ftp.jpg`: execução e validação do teste de autenticação no serviço FTP;
- `05-smb-spraying.jpg`: enumeração SMB e resultado do *password spraying*.

## 1. Serviço FTP (`21/tcp`)

A varredura inicial com Nmap confirmou a porta `21/tcp` aberta no endereço `192.168.56.102`. O teste foi executado com o Medusa utilizando as listas reduzidas do laboratório:

```bash
medusa -h 192.168.56.102 -U wordlists/usuarios-lab.txt -P wordlists/senhas-lab.txt -M ftp -t 1 -f -v 4
