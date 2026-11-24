# HO01: Fundamentos em Banco de Dados

> Respostas baseadas nos slides do Prof. Wladmir Cardoso Brandão (Tópicos #01 Introdução, #02 Modelo de Dados, #03 Esquema e Linguagem) e em Elmasri & Navathe (2016), caps. 1 e 2.

**1. O que é um sistema de banco de dados (SBD)?**
É o conjunto de dados relacionados e sua respectiva forma de acesso e organização. Ou seja, é composto por uma coleção de dados organizados, uma estrutura lógica que determina como os dados são armazenados, organizados e manipulados, e um software que dá acesso aos dados a usuários e aplicações.

**2. Do que um SBD é composto?**
- **Coleção de dados** → o banco de dados (BD);
- **Estrutura lógica** → o modelo de dados;
- **Software** → o sistema gerenciador de banco de dados (SGBD).

**3. Como usuários e aplicações interagem com um SBD?**
Submetendo **consultas**. O sistema interpreta cada consulta, faz as otimizações necessárias para executá-la corretamente, decide quais dados são necessários para respondê-la e se encarrega de recuperá-los dos repositórios sob seu controle.

**4. O que é um banco de dados (BD)? Cite um exemplo.**
É uma coleção de dados organizados (dados = símbolos, sinais, códigos) que atende às necessidades específicas de um grupo de usuários.
Exemplo: *IMDb — Internet Movie Database*, um BD de filmes, atores e diretores, disponível em https://www.imdb.com (dados abertos em https://developer.imdb.com/non-commercial-datasets/). Outro exemplo é o *The Human Genome Database (GDB)*.

**5. Quais são as propriedades de um BD?**
- **Finalidade** → é construído com um propósito específico;
- **Realidade** → representa o "mundo real" (minimundo ou universo de discurso);
- **Coerência** → mantém a coerência lógica da coleção;
- **Compartilhamento** → permite o compartilhamento dos dados.

**6. Quais são as etapas de um projeto de BD?**
1. Especificação → descrição do minimundo;
2. Análise de Requisitos → restrições de operação;
3. Projeto Conceitual → estruturas e restrições conceituais;
4. Projeto Lógico → estruturas e restrições lógicas;
5. Projeto Físico → estruturas e restrições físicas.

O projeto é revisado continuamente para que o BD reflita o estado do minimundo.

**7. O que é um sistema gerenciador de banco de dados (SGBD)?**
É uma coleção de programas (software) que permite aos usuários criar e manter BDs, ou seja:
- **Definir** → especificar tipos, estruturas e restrições, guardados como metadados no catálogo (dicionário) do sistema;
- **Construir** → armazenar os dados em um meio controlado pelo SGBD;
- **Manipular** → inserir, remover, modificar e recuperar dados;
- **Compartilhar** → dar acesso simultâneo a vários usuários.

**8. Quais são as propriedades de um SGBD?**
Controle de redundância, flexibilidade, múltiplas interfaces, economia de escala, garantia de padrões, restrições de acesso, backup e recuperação, disponibilidade elevada, restrições de integridade, redução do tempo de desenvolvimento e representação de relacionamentos complexos.
A abordagem de SGBD também oferece: repositório único, abstração de dados, natureza autodescritiva, compartilhamento de dados, isolamento entre programas e dados, suporte a múltiplas visões e processamento de transações multiusuário.

**9. Indique situações em que o uso de SGBD pode se mostrar inadequado.**
- **Monousuário** → não há necessidade de acesso por vários usuários;
- **Baixa complexidade** → aplicações muito simples e bem definidas;
- **Requisitos rigorosos** → aplicações de tempo real, de altíssima escalabilidade ou sistemas embarcados com pouca capacidade de armazenamento;
- **Alta especialização** → aplicações que precisam de recursos que a generalidade do SGBD não oferece (ex.: funções de segurança sofisticadas);
- **Custo proibitivo** → investimento inicial alto em hardware, software e treinamento.

**10. O que é um modelo de dados?**
É a estrutura lógica que determina como os dados são armazenados, organizados e manipulados. É uma coleção de conceitos que descrevem a estrutura do BD (tipos, relacionamentos e restrições) e inclui operações para especificar atualizações e consultas (inserir, remover, modificar, recuperar). É por meio dele que se alcança a abstração de dados.

**11. Em relação ao nível de abstração, quais são os tipos de modelos de dados?**
- **Conceitual** (alto nível) → representa a estrutura como os usuários a percebem. Conceitos: entidade, atributo e relacionamento;
- **Representativo ou de implementação** (nível intermediário) → mostra aspectos de implementação, mas esconde o armazenamento físico. Conceitos: objeto, relação, tupla e coluna. Exemplos: hierárquico, rede, objeto, relacional;
- **Físico** (baixo nível) → descreve como os dados são armazenados na memória. Conceitos: arquivo, registro, campo e índice.

**12. O que é um Esquema de BD?**
É a descrição do banco de dados (metadados). É especificado durante o projeto e não muda com frequência. É representado por um **diagrama de esquema**, que mostra a estrutura de cada tipo de elemento (construtor de esquema), mas **não** mostra as instâncias.

**13. O que é uma Instância de BD?**
É o conjunto de dados armazenados no BD em um determinado momento (também chamado de estado do BD).
- **Estado vazio** → o esquema foi especificado, mas nenhum dado foi armazenado;
- **Estado inicial** → o BD foi carregado (populado) com os dados iniciais.

O estado muda sempre que um item é inserido, removido ou modificado.

**14. Quais as vantagens de se adotar uma Arquitetura de Três Esquemas?**
Ela permite ver o esquema em diferentes níveis, oferecendo:
- **Autodescrição** → metadados descritivos em diferentes níveis de abstração;
- **Suporte a múltiplas visões** → usuários e aplicações acessam apenas as porções do BD de que precisam;
- **Independência de aplicação** → a estrutura do BD fica separada das aplicações, então mudar a estrutura não obriga a mudar as aplicações (independência de dados).

**15. Quais níveis existem em uma Arquitetura de Três Esquemas?**
- **Externo** → esquemas externos (visões de usuário). Cada visão descreve a parte do BD que interessa a um grupo de usuários e esconde o resto;
- **Conceitual** → esquema conceitual: estrutura do BD inteiro (entidades, tipos de dados, relacionamentos, restrições, operações), sem detalhes de armazenamento físico;
- **Interno** → esquema interno (físico): estrutura do armazenamento físico e caminhos de acesso.

**16. O que é Mapeamento em uma Arquitetura de Três Esquemas?**
É a transformação de requisições e resultados entre os níveis. O SGBD transforma uma solicitação feita sobre um esquema externo em uma solicitação sobre o esquema conceitual e, depois, sobre o esquema interno, para processá-la sobre os dados armazenados. Os resultados percorrem o caminho inverso.

**17. O que é Independência de Dados e qual sua importância para um SBD?**
É a capacidade de alterar o esquema de um nível sem precisar alterar o esquema do nível adjacente superior.
- **Lógica** → alterar o esquema conceitual sem alterar os esquemas externos. Ex.: ao acrescentar ou remover um tipo de dado, só mudam o mapeamento e a definição da visão;
- **Física** → alterar o esquema interno sem alterar o esquema conceitual. Ex.: ao criar estruturas de acesso adicionais (índices), só muda o mapeamento.

Importância: as aplicações e os usuários ficam isolados das mudanças estruturais, o que reduz custo de manutenção e permite evoluir o BD. A independência lógica é mais difícil de alcançar que a física.

**18. O que é uma Linguagem de Consulta?**
É uma linguagem de **alto nível, não procedural (declarativa)**: especifica *quais* dados recuperar, e não *como* recuperá-los. Permite operações complexas de forma concisa, recuperando muitos registros em uma única instrução. Recebe esse nome porque é usada de forma interativa. Já as linguagens de baixo nível (procedurais) ficam embutidas em uma linguagem hospedeira e são chamadas de sublinguagem de dados.

**19. Cite as linguagens incorporadas na linguagem SQL.**
- **VDL** (*View Definition Language*) → define o esquema externo (visões) e seu mapeamento para o conceitual;
- **DDL** (*Data Definition Language*) → define o esquema conceitual;
- **SDL** (*Storage Definition Language*) → define o esquema interno;
- **DML** (*Data Manipulation Language*) → inserção, exclusão, modificação e recuperação de dados.

A SQL também inclui instruções para especificar restrições, evoluir o esquema, entre outros recursos.
