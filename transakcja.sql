SELECT 
    clients.id AS klient_id,
    clients.first_name,
    clients.last_name,
    cars.id AS samochod_id,
    cars.marka,
    cars.model,
    cars.rok,
    clients.email,
    

    (
        CASE
            WHEN CAST(cars.rok AS UNSIGNED) BETWEEN 1940 AND 1979 THEN 1300
            WHEN CAST(cars.rok AS UNSIGNED) BETWEEN 1980 AND 1999 THEN 2200
            WHEN CAST(cars.rok AS UNSIGNED) BETWEEN 2000 AND 2015 THEN 2500
            ELSE 1000
          END
    ) AS cena_bazowa_zł,
    

    (
        (
        CASE
            WHEN CAST(cars.rok AS UNSIGNED) BETWEEN 1940 AND 1979 THEN 1300
            WHEN CAST(cars.rok AS UNSIGNED) BETWEEN 1980 AND 1999 THEN 2200
            WHEN CAST(cars.rok AS UNSIGNED) BETWEEN 2000 AND 2015 THEN 2500
            ELSE 1000
          END)
        * 
        CASE
            WHEN clients.email LIKE '%apple%' THEN 1.4
            ELSE 1
        END
        *
        CASE
            WHEN clients.country IN ('Polska', 'Chiny') THEN 0.7
            ELSE 1
        END
        *
        (1 - (
            (SELECT COUNT(*) * 0.05 
             FROM cars AS c2 
             WHERE c2.client_id = clients.id)
        ))
    ) AS cena_po_rabatach_zł

FROM clients
JOIN cars ON clients.id = cars.client_id
ORDER BY cena_po_rabatach_zł DESC;
