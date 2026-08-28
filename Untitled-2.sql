-- Task 1: Script with variable for high-balance invoices
DECLARE @count INT;

SELECT @count = COUNT(*) 
FROM dbo.Invoices
WHERE InvoiceTotal - PaymentTotal - CreditTotal > 5000;

PRINT CAST(@count AS VARCHAR) + ' invoices exceed $5,000.';
GO

-- Task 2: Script for unpaid invoices and conditional result set
DECLARE @count INT, @sum MONEY;

SELECT @count = COUNT(*), 
       @sum = SUM(InvoiceTotal - PaymentTotal - CreditTotal)
FROM dbo.Invoices 
WHERE InvoiceTotal - PaymentTotal - CreditTotal > 0;

PRINT 'Number of unpaid invoices is ' + CAST(@count AS VARCHAR) + '.';
PRINT 'Total balance due is $' + CONVERT(VARCHAR, @sum, 1) + '.';

IF @sum >= 10000
    SELECT v.VendorName, i.InvoiceNumber, i.InvoiceDueDate, 
           i.InvoiceTotal - i.PaymentTotal - i.CreditTotal AS Balance
    FROM dbo.Invoices AS i
    JOIN dbo.Vendors AS v
      ON i.VendorID = v.VendorID
    WHERE i.InvoiceTotal - i.PaymentTotal - i.CreditTotal > 0
    ORDER BY i.InvoiceDueDate;
ELSE
    PRINT 'Total balance due is less than $10,000.';
GO

-- Task 3: Stored procedure for vendors without invoices
CREATE PROC spVendorsWithoutInvoices
    @VendorName VARCHAR(50)
AS
    SELECT VendorID, VendorName
    FROM dbo.Vendors
    WHERE VendorID NOT IN (SELECT VendorID FROM dbo.Invoices)
      AND VendorName LIKE '%' + @VendorName + '%'
    ORDER BY VendorName;
GO

-- Testing Task 3
EXEC spVendorsWithoutInvoices 'service';
EXEC spVendorsWithoutInvoices 'services';
GO

-- Task 4: Stored procedure with optional parameter and output parameter
CREATE PROC spVendorStateInvTotal
    @VendorState CHAR(2) = NULL,
    @SumInvoiceTotal MONEY OUTPUT
AS
    SELECT @SumInvoiceTotal = SUM(i.InvoiceTotal)
    FROM dbo.Invoices AS i
    JOIN dbo.Vendors AS v
      ON i.VendorID = v.VendorID
    WHERE (@VendorState IS NULL OR v.VendorState LIKE @VendorState);
GO

-- Testing Task 4
DECLARE @TotalInv MONEY;

-- a. Without providing @VendorState
EXEC spVendorStateInvTotal @SumInvoiceTotal = @TotalInv OUTPUT;
PRINT 'Total (All States): ' + CAST(@TotalInv AS VARCHAR);

-- b. With @VendorState = 'tx'
EXEC spVendorStateInvTotal 'tx', @TotalInv OUTPUT;
PRINT 'Total (TX): ' + CAST(@TotalInv AS VARCHAR);

-- c. With @VendorState = 't%'
EXEC spVendorStateInvTotal 't%', @TotalInv OUTPUT;
PRINT 'Total (T%): ' + CAST(@TotalInv AS VARCHAR);
GO