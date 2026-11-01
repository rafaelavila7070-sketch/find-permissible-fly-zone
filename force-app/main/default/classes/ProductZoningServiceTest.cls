
@IsTest
private class ProductZoningServiceTest {

    @TestSetup
    static void createTestProducts() {

        List<Product_Geo_Mapping__mdt> mappings = [
            SELECT Product_Family__c
            FROM Product_Geo_Mapping__mdt
        ];

        Set<String> families = new Set<String>();

        for (Product_Geo_Mapping__mdt mapping : mappings) {
            if (String.isNotBlank(mapping.Product_Family__c)) {
                families.add(mapping.Product_Family__c);
            }
        }

        List<Product2> products = new List<Product2>();
        Integer counter = 1;

        for (String family : families) {
            products.add(new Product2(
                Name = 'Test Product ' + counter,
                ProductCode = 'TEST-' + counter,
                Family = family,
                IsActive = true
            ));

            counter++;
        }

        insert products;
    }

    private static String executeRequest(
        String productCode,
        String countryCode
    ) {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.requestUri = '/services/apexrest/ProductZoning/';
        request.httpMethod = 'GET';

        if (productCode != null) {
            request.addParameter('ProductCode', productCode);
        }

        if (countryCode != null) {
            request.addHeader('CountryCode', countryCode);
        }

        RestContext.request = request;
        RestContext.response = response;

        return ProductZoningService.getPermissibleFlyZone();
    }

    private static Product2 findProduct(String family) {
        return [
            SELECT Id, ProductCode, Family
            FROM Product2
            WHERE Family = :family
            LIMIT 1
        ];
    }

    @IsTest
    static void testSuccessfulCountryMapping() {

        Product_Geo_Mapping__mdt mapping = [
            SELECT Product_Family__c, Country_Code__c,
                   Permissible_Fly_Zone__c
            FROM Product_Geo_Mapping__mdt
            WHERE Country_Code__c = 'AU'
            LIMIT 1
        ];

        Product2 product = findProduct(mapping.Product_Family__c);

        Test.startTest();
        String result = executeRequest(
            product.ProductCode,
            mapping.Country_Code__c
        );
        Test.stopTest();

        System.assertEquals(
            mapping.Permissible_Fly_Zone__c,
            result
        );
    }

    @IsTest
    static void testDefaultCountryUS() {

        Product_Geo_Mapping__mdt mapping = [
            SELECT Product_Family__c, Permissible_Fly_Zone__c
            FROM Product_Geo_Mapping__mdt
            WHERE Country_Code__c = 'US'
            LIMIT 1
        ];

        Product2 product = findProduct(mapping.Product_Family__c);

        Test.startTest();
        String result = executeRequest(product.ProductCode, null);
        Test.stopTest();

        System.assertEquals(
            mapping.Permissible_Fly_Zone__c,
            result
        );
    }

    @IsTest
    static void testMissingProductCode() {

        Test.startTest();
        String result = executeRequest(null, 'US');
        Test.stopTest();

        System.assertEquals(
            'ProductCode is missing or doesn\'t exist',
            result
        );
    }

    @IsTest
    static void testNonexistentProductCode() {

        Test.startTest();
        String result = executeRequest(
            'PRODUCT-DOES-NOT-EXIST',
            'US'
        );
        Test.stopTest();

        System.assertEquals(
            'ProductCode is missing or doesn\'t exist',
            result
        );
    }

    @IsTest
    static void testMissingGeoMapping() {

        Product2 product = [
            SELECT Id, ProductCode
            FROM Product2
            LIMIT 1
        ];

        Test.startTest();
        String result = executeRequest(product.ProductCode, 'ZZ');
        Test.stopTest();

        System.assertEquals(
            'Confirm with the local authorities',
            result
        );
    }
}
