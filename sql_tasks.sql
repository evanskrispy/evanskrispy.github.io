-- Task 1: Count invoices with balance due > $5,000
DECLARE @count INT;
SELECT @count = COUNT(*) 
FROM Invoices 
WHERE InvoiceTotal - PaymentTotal - CreditTotal > 5000;
PRINT CAST(@count AS VARCHAR) + ' invoices exceed $5,000.';

GO

-- Task 2: Count and sum unpaid invoices, conditional result set
DECLARE @count INT, @sum DECIMAL(10,2);
SELECT @count = COUNT(*), @sum = SUM(InvoiceTotal - PaymentTotal - CreditTotal) 
FROM Invoices 
WHERE InvoiceTotal - PaymentTotal - CreditTotal > 0;

PRINT 'Number of unpaid invoices is ' + CAST(@count AS VARCHAR) + '.';
PRINT 'Total balance due is $' + CAST(@sum AS VARCHAR) + '.';

IF @sum >= 10000
BEGIN
    SELECT V.VendorName, I.InvoiceNumber, I.InvoiceDueDate, 
           I.InvoiceTotal - I.PaymentTotal - I.CreditTotal AS Balance
    FROM Invoices I 
    JOIN Vendors V ON I.VendorID = V.VendorID
    WHERE I.InvoiceTotal - I.PaymentTotal - I.CreditTotal > 0
    ORDER BY I.InvoiceDueDate;
END
ELSE
BEGIN
    PRINT 'Total balance due is less than $10,000.';
END

GO

-- Task 3: Stored procedure for vendors without invoices
CREATE PROCEDURE spVendorsWithoutInvoices
    @VendorName VARCHAR(50)
AS
BEGIN
    SELECT VendorID, VendorName
    FROM Vendors
    WHERE VendorName LIKE '%' + @VendorName + '%'
    AND VendorID NOT IN (SELECT VendorID FROM Invoices)
    ORDER BY VendorName;
END;

GO

-- Call the procedure with 'service'
EXEC spVendorsWithoutInvoices 'service';

GO

-- Call the procedure with 'services'
EXEC spVendorsWithoutInvoices 'services';

GO

-- Task 4: Stored procedure for vendor state invoice total
CREATE PROCEDURE spVendorStateInvTotal
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

-- Call without @VendorState
DECLARE @total DECIMAL(10,2);
EXEC spVendorStateInvTotal NULL, @total OUTPUT;
PRINT @total;

GO

-- Call with @VendorState = 'tx'
EXEC spVendorStateInvTotal 'tx', @total OUTPUT;
PRINT @total;

GO

-- Call with @VendorState = 't%'
EXEC spVendorStateInvTotal 't%', @total OUTPUT;
PRINT @total;

GO