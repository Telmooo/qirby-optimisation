---- On insert in municipalities, insert the new municipality to its appropriate NUTS III
CREATE OR REPLACE TRIGGER municipality_insert_trg
   AFTER INSERT ON municipalities
REFERENCING NEW AS NEW
FOR EACH ROW
BEGIN
    INSERT INTO TABLE(
        SELECT n3.municipalities
            FROM nuts_3 n3
            WHERE REF(n3) = :NEW.nuts_3
    ) VALUES ((
        SELECT REF(m) FROM municipalities m WHERE m.code = :NEW.code
    ));
END municipality_insert_trg;
/