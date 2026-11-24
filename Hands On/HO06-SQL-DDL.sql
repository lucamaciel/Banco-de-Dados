-- =====================================================================
-- HO06: SQL (DDL) — Banco de dados SAM (v1.0)
-- Base: script do próprio Prof. Wladmir Brandão (aulas/relational/specs/SAM/SAM.tex,
--       "Anexos: Scripts de Banco de Dados"), gerado no MySQL Workbench.
-- Acrescentei CHECKs para as restrições de VALOR. O professor usa gatilhos
-- (triggers), que também estão no final do arquivo.
-- =====================================================================
--
-- 1) DIAGRAMA DE IMPLEMENTAÇÃO (Pé de Galinha / Crow's Foot)
--    Legenda: ||  = exatamente um   |o = zero ou um
--             |< = um ou muitos     o< = zero ou muitos
--
--   AREA ||----o< CURSO        (todo curso tem 1 área; área tem 0..N cursos)
--   AREA |o----o< AREA         (SuperArea: área integra 0..1 área)
--   CURSO ||----o< MODULO      (módulo pertence a exatamente 1 curso)
--   MODULO ||----o< TOPICO     (tópico depende de 1 módulo — identificador)
--   CURSO ||----o< MATRICULA >o----|| ALUNO   (M:N resolvido por MATRICULA)
--   CURSO ||----o< PROFESSOR   (atributo multivalorado de CURSO)
--
--   ┌───────────────┐        ┌────────────────┐
--   │ AREA          │        │ CURSO          │
--   │ PK Sigla      │||───o<│ PK Sigla       │
--   │    Nome (UQ)  │        │    Nome        │
--   │ FK SuperArea ─┼─┐      │    Horas       │
--   └───────────────┘ │      │    Custo       │
--        ▲ |o─────────┘      │ FK Area        │
--                            └────────────────┘
--   ┌───────────────┐  ||──o<  MODULO(PK Sigla, Nome, FK Curso)
--   │ ALUNO         │          ||──o< TOPICO(PK/FK Modulo, PK Sigla, Nome, Horas)
--   │ PK CPF        │||──o< MATRICULA(PK/FK Curso, PK/FK Aluno, Data, Pago)
--   │ Nome,Sobrenome│          CURSO ||──o< MATRICULA
--   │ Sexo,DataNasc │          CURSO ||──o< PROFESSOR(PK/FK Curso, PK CPF, Nome)
--   └───────────────┘
--   (Desenhe no MySQL Workbench / draw.io: EER Diagram → Crow's Foot.)
-- =====================================================================

-- 2) CONSULTAS SQL (MySQL)

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- ---------- Esquema ----------
DROP SCHEMA IF EXISTS `SAM`;
CREATE SCHEMA IF NOT EXISTS `SAM` DEFAULT CHARACTER SET utf8;
USE `SAM`;

-- ---------- Tabelas (domínio + nulidade + valor padrão) ----------
CREATE TABLE IF NOT EXISTS `Aluno` (
  `CPF`       CHAR(11)     NOT NULL,
  `Nome`      VARCHAR(150) NOT NULL,
  `Sobrenome` VARCHAR(80)  NOT NULL,
  `Sexo`      CHAR(1)      NOT NULL,
  `DataNasc`  DATE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Area` (
  `Sigla`     CHAR(8)      NOT NULL,
  `Nome`      VARCHAR(120) NOT NULL,
  `SuperArea` CHAR(8)      NULL
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Curso` (
  `Sigla` CHAR(8)       NOT NULL,
  `Nome`  VARCHAR(250)  NOT NULL,
  `Horas` INT           NULL,          -- derivado (soma das horas dos tópicos)
  `Custo` DECIMAL(12,2) NOT NULL,
  `Area`  CHAR(8)       NOT NULL       -- participação total
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Matricula` (
  `Curso` CHAR(8)  NOT NULL,
  `Aluno` CHAR(11) NOT NULL,
  `Data`  DATE     NOT NULL,
  `Pago`  TINYINT  NOT NULL DEFAULT 0  -- valor padrão
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Modulo` (
  `Sigla` CHAR(8)      NOT NULL,
  `Nome`  VARCHAR(250) NOT NULL,
  `Curso` CHAR(8)      NOT NULL        -- não existe módulo sem curso
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Professor` (
  `Curso` CHAR(8)      NOT NULL,
  `CPF`   CHAR(11)     NOT NULL,
  `Nome`  VARCHAR(250) NOT NULL
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `Topico` (
  `Modulo` CHAR(8)      NOT NULL,
  `Sigla`  CHAR(3)      NOT NULL,
  `Nome`   VARCHAR(250) NOT NULL,
  `Horas`  INT          NOT NULL
) ENGINE = InnoDB;

-- ---------- Chaves primárias ----------
ALTER TABLE `Aluno`     ADD CONSTRAINT `PK_Aluno`     PRIMARY KEY (`CPF`);
ALTER TABLE `Area`      ADD CONSTRAINT `PK_Area`      PRIMARY KEY (`Sigla`);
ALTER TABLE `Curso`     ADD CONSTRAINT `PK_Curso`     PRIMARY KEY (`Sigla`);
ALTER TABLE `Matricula` ADD CONSTRAINT `PK_Matricula` PRIMARY KEY (`Curso`, `Aluno`);
ALTER TABLE `Modulo`    ADD CONSTRAINT `PK_Modulo`    PRIMARY KEY (`Sigla`);
ALTER TABLE `Professor` ADD CONSTRAINT `PK_Professor` PRIMARY KEY (`Curso`, `CPF`);
ALTER TABLE `Topico`    ADD CONSTRAINT `PK_Topico`    PRIMARY KEY (`Modulo`, `Sigla`);

-- ---------- Unicidade ----------
ALTER TABLE `Area` ADD CONSTRAINT `UN_Area_Nome` UNIQUE (`Nome`);

-- ---------- Valor (CHECK — MySQL 8.0.16+) ----------
ALTER TABLE `Aluno`     ADD CONSTRAINT `CK_Aluno_Sexo`   CHECK (`Sexo` IN ('F','M'));
ALTER TABLE `Curso`     ADD CONSTRAINT `CK_Curso_Horas`  CHECK (`Horas` IS NULL OR `Horas` > 0);
ALTER TABLE `Curso`     ADD CONSTRAINT `CK_Curso_Custo`  CHECK (`Custo` >= 0);
ALTER TABLE `Matricula` ADD CONSTRAINT `CK_Matr_Pago`    CHECK (`Pago` IN (0,1));
ALTER TABLE `Topico`    ADD CONSTRAINT `CK_Topico_Horas` CHECK (`Horas` > 0);

-- ---------- Integridade referencial ----------
ALTER TABLE `Area` ADD CONSTRAINT `FK_Area_Area`
  FOREIGN KEY (`SuperArea`) REFERENCES `Area` (`Sigla`)
  ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE `Curso` ADD CONSTRAINT `FK_Curso_Area`
  FOREIGN KEY (`Area`) REFERENCES `Area` (`Sigla`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `Matricula` ADD CONSTRAINT `FK_Matricula_Curso`
  FOREIGN KEY (`Curso`) REFERENCES `Curso` (`Sigla`)
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE `Matricula` ADD CONSTRAINT `FK_Matricula_Aluno`
  FOREIGN KEY (`Aluno`) REFERENCES `Aluno` (`CPF`)
  ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `Modulo` ADD CONSTRAINT `FK_Modulo_Curso`
  FOREIGN KEY (`Curso`) REFERENCES `Curso` (`Sigla`)
  ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `Professor` ADD CONSTRAINT `FK_Professor_Curso`
  FOREIGN KEY (`Curso`) REFERENCES `Curso` (`Sigla`)
  ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `Topico` ADD CONSTRAINT `FK_Topico_Modulo`
  FOREIGN KEY (`Modulo`) REFERENCES `Modulo` (`Sigla`)
  ON DELETE CASCADE ON UPDATE CASCADE;

-- ---------- Índices nas chaves estrangeiras (projeto físico do professor) ----------
CREATE INDEX `IDX_FK_Area_Area`       ON `Area`      (`SuperArea` ASC);
CREATE INDEX `IDX_FK_Curso_Area`      ON `Curso`     (`Area` ASC);
CREATE INDEX `IDX_FK_Matricula_Aluno` ON `Matricula` (`Aluno` ASC);
CREATE INDEX `IDX_FK_Modulo_Curso`    ON `Modulo`    (`Curso` ASC);
CREATE INDEX `IDX_FK_Professor_Curso` ON `Professor` (`Curso` ASC);
CREATE INDEX `IDX_FK_Topico_Modulo`   ON `Topico`    (`Modulo` ASC);

-- ---------- Restrições de valor via gatilhos (versão do professor) ----------
DELIMITER $$
DROP TRIGGER IF EXISTS `Aluno_BEFORE_UPDATE`$$
CREATE TRIGGER `Aluno_BEFORE_UPDATE` BEFORE UPDATE ON `Aluno` FOR EACH ROW
BEGIN
  IF NEW.Sexo = 'f' THEN SET NEW.Sexo = 'F';
  ELSEIF NEW.Sexo = 'm' THEN SET NEW.Sexo = 'M';
  END IF;
  IF NEW.Sexo <> 'F' AND NEW.Sexo <> 'M' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sexo invalido: F ou M';
  END IF;
END$$

DROP TRIGGER IF EXISTS `Curso_BEFORE_UPDATE`$$
CREATE TRIGGER `Curso_BEFORE_UPDATE` BEFORE UPDATE ON `Curso` FOR EACH ROW
BEGIN
  IF NEW.Horas < 1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Horas invalida: Horas > 0';
  END IF;
END$$

DROP TRIGGER IF EXISTS `Matricula_BEFORE_UPDATE`$$
CREATE TRIGGER `Matricula_BEFORE_UPDATE` BEFORE UPDATE ON `Matricula` FOR EACH ROW
BEGIN
  IF NEW.Pago <> 0 AND NEW.Pago <> 1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pago invalido: 0 ou 1';
  END IF;
END$$

DROP TRIGGER IF EXISTS `Topico_BEFORE_UPDATE`$$
CREATE TRIGGER `Topico_BEFORE_UPDATE` BEFORE UPDATE ON `Topico` FOR EACH ROW
BEGIN
  IF NEW.Horas < 1 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Horas invalida: Horas > 0';
  END IF;
END$$
DELIMITER ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
