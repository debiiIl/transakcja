SELECT 
    cl.id AS klient_id,
    cl.first_name,
    cl.last_name,
    c.id AS samochod_id,
    c.marka,
    c.model,
    c.rok,
    cl.email,

    -- Cena bazowa według rocznika
    CASE
        WHEN CAST(c.rok AS UNSIGNED) BETWEEN 1940 AND 1979 THEN 1300
        WHEN CAST(c.rok AS UNSIGNED) BETWEEN 1980 AND 1999 THEN 2200
        WHEN CAST(c.rok AS UNSIGNED) BETWEEN 2000 AND 2015 THEN 2500
        ELSE 1000
    END AS cena_bazowa_zł,

    -- Kwota rabatu krajowego
    ROUND(
        CASE
            WHEN CAST(c.rok AS UNSIGNED) BETWEEN 1940 AND 1979 THEN 1300
            WHEN CAST(c.rok AS UNSIGNED) BETWEEN 1980 AND 1999 THEN 2200
            WHEN CAST(c.rok AS UNSIGNED) BETWEEN 2000 AND 2015 THEN 2500
            ELSE 1000
        END
        * CASE WHEN cl.country IN ('Polska','Chiny') THEN 0.3 ELSE 0 END
    , 2) AS kwota_rabat_krajowy_zł,

    -- Kwota dopłaty za e-mail
    ROUND(
        CASE
            WHEN CAST(c.rok AS UNSIGNED) BETWEEN 1940 AND 1979 THEN 1300
            WHEN CAST(c.rok AS UNSIGNED) BETWEEN 1980 AND 1999 THEN 2200
            WHEN CAST(c.rok AS UNSIGNED) BETWEEN 2000 AND 2015 THEN 2500
            ELSE 1000
        END
        * CASE WHEN cl.email LIKE '%apple%' THEN 0.4 ELSE 0 END
    , 2) AS kwota_doplata_email_zł,

    -- Kwota rabatu za liczbę samochodów (sumaryczny, max 90% ceny bazowej)
    ROUND(
        CASE
            WHEN CAST(c.rok AS UNSIGNED) BETWEEN 1940 AND 1979 THEN 1300
            WHEN CAST(c.rok AS UNSIGNED) BETWEEN 1980 AND 1999 THEN 2200
            WHEN CAST(c.rok AS UNSIGNED) BETWEEN 2000 AND 2015 THEN 2500
            ELSE 1000
        END
        * LEAST((SELECT COUNT(*) * 0.05 FROM cars c2 WHERE c2.client_id = cl.id), 0.9)
    , 2) AS kwota_rabat_za_liczbe_samochodow_zł,

    -- Finalna cena po wszystkich rabatach i dopłatach
    ROUND(
        CASE
            WHEN CAST(c.rok AS UNSIGNED) BETWEEN 1940 AND 1979 THEN 1300
            WHEN CAST(c.rok AS UNSIGNED) BETWEEN 1980 AND 1999 THEN 2200
            WHEN CAST(c.rok AS UNSIGNED) BETWEEN 2000 AND 2015 THEN 2500
            ELSE 1000
        END
        - 
        -- sumujemy rabaty procentowe w złotówkach
        CASE
            WHEN CAST(c.rok AS UNSIGNED) BETWEEN 1940 AND 1979 THEN 1300
            WHEN CAST(c.rok AS UNSIGNED) BETWEEN 1980 AND 1999 THEN 2200
            WHEN CAST(c.rok AS UNSIGNED) BETWEEN 2000 AND 2015 THEN 2500
            ELSE 1000
        END
        * LEAST(
            (CASE WHEN cl.country IN ('Polska','Chiny') THEN 0.3 ELSE 0 END) +
            (SELECT COUNT(*) * 0.05 FROM cars c2 WHERE c2.client_id = cl.id),
            0.9
        )
        +
        -- dopłata za e-mail
        CASE
            WHEN CAST(c.rok AS UNSIGNED) BETWEEN 1940 AND 1979 THEN 1300
            WHEN CAST(c.rok AS UNSIGNED) BETWEEN 1980 AND 1999 THEN 2200
            WHEN CAST(c.rok AS UNSIGNED) BETWEEN 2000 AND 2015 THEN 2500
            ELSE 1000
        END
        * CASE WHEN cl.email LIKE '%apple%' THEN 0.4 ELSE 0 END
    , 2) AS cena_po_rabatach_zł

FROM clients cl
JOIN cars c ON cl.id = c.client_id
ORDER BY cena_po_rabatach_zł DESC;
