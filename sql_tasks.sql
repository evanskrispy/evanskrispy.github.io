--task1
DECLARE @count INT;

SELECT @count = COUNT(*) 
FROM Invoices 
WHERE (InvoiceTotal - PaymentTotal - CreditTotal) > 5000;

PRINT CAST(@count AS VARCHAR) + ' invoices exceed $5,000.';
GO

-- Task2
DECLARE @count INT, @sum DECIMAL(10,2);

SELECT @count = COUNT(*), 
       @sum = SUM(InvoiceTotal - PaymentTotal - CreditTotal) 
FROM Invoices 
WHERE (InvoiceTotal - PaymentTotal - CreditTotal) > 0;

IF @sum >= 10000
BEGIN
    PRINT 'Number of unpaid invoices is ' + CAST(@count AS VARCHAR) + '.';
    PRINT 'Total balance due is $' + CONVERT(VARCHAR, @sum, 1) + '.';

    SELECT V.VendorName, I.InvoiceNumber, I.InvoiceDueDate, 
           (I.InvoiceTotal - I.PaymentTotal - I.CreditTotal) AS Balance
    FROM Invoices I 
    JOIN Vendors V ON I.VendorID = V.VendorID
    WHERE (I.InvoiceTotal - I.PaymentTotal - I.CreditTotal) > 0
    ORDER BY I.InvoiceDueDate;
END
ELSE
BEGIN
    PRINT 'Total balance due is less than $10,000.';
END
GO

-- Task3
CREATE OR ALTER PROCEDURE spVendorsWithoutInvoices
    @VendorName VARCHAR(50)
AS
BEGIN
    SELECT V.VendorID, V.VendorName
    FROM Vendors V
    WHERE V.VendorName LIKE '%' + @VendorName + '%'
      AND NOT EXISTS (SELECT 1 FROM Invoices I WHERE I.VendorID = V.VendorID)
    ORDER BY V.VendorName;
END;
GO

-- Execution
EXEC spVendorsWithoutInvoices 'service';
EXEC spVendorsWithoutInvoices 'services';
GO

-- Task 4
CREATE OR ALTER PROCEDURE spVendorStateInvTotal
    @VendorState VARCHAR(2) = NULL,
    @SumInvoiceTotal DECIMAL(10,2) OUTPUT
AS
BEGIN
    SELECT @SumInvoiceTotal = SUM(InvoiceTotal)
    FROM Invoices I 
    JOIN Vendors V ON I.VendorID = V.VendorID
    WHERE (@VendorState IS NULL OR V.VendorState LIKE @VendorState);
END;

GO

-- Calling the procedure
DECLARE @total DECIMAL(10,2);

-- a. Without @VendorState
EXEC spVendorStateInvTotal DEFAULT, @total OUTPUT;
PRINT 'Total (All States): ' + CAST(@total AS VARCHAR);

-- b. With 'tx'
EXEC spVendorStateInvTotal 'tx', @total OUTPUT;
PRINT 'Total (TX): ' + CAST(@total AS VARCHAR);

-- c. With 't%'
EXEC spVendorStateInvTotal 't%', @total OUTPUT;
PRINT 'Total (T%): ' + CAST(@total AS VARCHAR);
GO