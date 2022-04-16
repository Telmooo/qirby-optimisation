-- Primary Keys
ALTER TABLE YDOCENTES
    ADD CONSTRAINT ydocentes_pk PRIMARY KEY(NR);

ALTER TABLE YDSD
    ADD CONSTRAINT ydsd_pk PRIMARY KEY(NR, ID);

ALTER TABLE YTIPOSAULA
    ADD CONSTRAINT ytiposaula_pk PRIMARY KEY(ID);

ALTER TABLE YOCORRENCIAS
    ADD CONSTRAINT yocorrencias_pk PRIMARY KEY(CODIGO, ANO_LETIVO, PERIODO);

ALTER TABLE YUCS
    ADD CONSTRAINT yucs_pk PRIMARY KEY(CODIGO);
-- Foreign Keys
ALTER TABLE YDSD
    ADD CONSTRAINT ydsd_nr_fk FOREIGN KEY(NR) REFERENCES YDOCENTES(NR);

ALTER TABLE YDSD
    ADD CONSTRAINT ydsd_id_fk FOREIGN KEY(ID) REFERENCES YTIPOSAULA(ID);

ALTER TABLE YTIPOSAULA
    ADD CONSTRAINT ytiposaula_fk FOREIGN KEY(ANO_LETIVO,PERIODO, CODIGO) REFERENCES YOCORRENCIAS(ANO_LETIVO, PERIODO, CODIGO);

ALTER TABLE YOCORRENCIAS
    ADD CONSTRAINT yocorrencias_fk FOREIGN KEY(CODIGO) REFERENCES YUCS(CODIGO);
