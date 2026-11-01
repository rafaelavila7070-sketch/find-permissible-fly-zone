
@RestResource(urlMapping='/ProductZoning/*')
global with sharing class ProductZoningService {

    @HttpGet
    global static String getPermissibleFlyZone() {

        RestRequest request = RestContext.request;

        String productCode = request.params.get('ProductCode');
        String countryCode = request.headers.get('CountryCode');

        if (String.isBlank(productCode)) {
            return 'ProductCode is missing or doesn\'t exist';
        }

        if (String.isBlank(countryCode)) {
            countryCode = 'US';
        }

        List<Product2> products = [
            SELECT Id, Family
            FROM Product2
            WHERE ProductCode = :productCode
            LIMIT 1
        ];

        if (products.isEmpty()) {
            return 'ProductCode is missing or doesn\'t exist';
        }

        String productFamily = products[0].Family;

        List<Product_Geo_Mapping__mdt> mappings = [
            SELECT Permissible_Fly_Zone__c
            FROM Product_Geo_Mapping__mdt
            WHERE Product_Family__c = :productFamily
            AND Country_Code__c = :countryCode
            LIMIT 1
        ];

        if (mappings.isEmpty()) {
            return 'Confirm with the local authorities';
        }

        return mappings[0].Permissible_Fly_Zone__c;
    }
}
