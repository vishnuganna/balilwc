/**
 * Class for generating JSON web tokens
 */
public with sharing class JWT {
    // algorithm types supported by Crypto.generateMac
    private Map<String, String> supportedAlgorithms = new Map<String, String>{ 'HS256' => 'hmacSHA256' };

    // class properties properties
    private final String algorithm;
    private final Map<String, String> properties;
    private final String privateKey;

    /**
     * Constructor for JWT class
     * @param algorithm algorithm to use
     * @param properties map of properties (key, values) to make up payload
     * @param privateKey private key for signature
     */
    public JWT(final String algorithm, final Map<String, String> properties, final String privateKey) {
        this.algorithm = algorithm;
        this.properties = properties;
        this.privateKey = privateKey;
    }

    /**
     * Issues JSON Web Token
     * @return String representing encoded JWT
     */
    public String issue() {
        String jwt = buildEncodedHeader() + '.' + buildEncodedPayload();
        if (this.supportedAlgorithms.keySet().contains(this.algorithm)) {
            jwt += '.' + buildEncodedSignature(this.supportedAlgorithms.get(this.algorithm), jwt);
        }
        return jwt;
    }

    /**
     * Builds JWT header
     * @return encoded JWT header data
     */
    private String buildEncodedHeader() {
        JSONGenerator header = JSON.createGenerator(false);
        header.writeStartObject();
        header.writeStringField('alg', this.algorithm);
        header.writeStringField('typ', 'JWT');
        header.writeEndObject();
        return base64URLEncode(Blob.valueOf(header.getAsString()));
    }

    /**
     * Builds JWT payload
     * @return encoded JWT payload
     */
    private String buildEncodedPayload() {
        JSONGenerator body = JSON.createGenerator(false);
        body.writeStartObject();
        // set issued time
        Long rightNow = (Datetime.now().getTime() / 1000) + 1;
        body.writeNumberField('iat', rightNow);
        // add all properties
        for (String key : this.properties.keySet()) {
            body.writeStringField(key, this.properties.get(key));
        }
        body.writeEndObject();
        return base64URLEncode(Blob.valueOf(body.getAsString()));
    }

    /**
     * Builds JWT signature
     * @param algoName Algorithm name for signature
     * @param payload Blog representing input for signature
     * @return encoded JWT signature
     */
    private String buildEncodedSignature(final String algoName, final String payload) {
        return base64URLEncode(Crypto.generateMac(algoName, Blob.valueOf(payload), Blob.valueOf(this.privateKey)));
    }

    /**
     * Helper method to encode data
     * @param input input to Base 64 encode
     * @return Base 64 encoded input
     */
    private String base64URLEncode(Blob input) {
        String output = EncodingUtil.base64Encode(input);
        output = output.replace('+', '-');
        output = output.replace('/', '_');
        while (output.endsWith('=')) {
            output = output.substring(0, output.length() - 1);
        }
        return output;
    }

    /**
     * Builder class for JWT objects
     */
    public with sharing class JWTBuilder {
        // attributes
        private String algorithm;
        private Map<String, String> properties;
        private String privateKey;

        // setters for builder pattern
        public JWTBuilder setAlgorithm(final String algorithm) {
            this.algorithm = algorithm;
            return this;
        }
        public JWTBuilder setProperty(final String key, final String value) {
            if (properties == null) {
                properties = new Map<String, String>();
            }
            properties.put(key, value);
            return this;
        }
        public JWTBuilder setPrivateKey(final String privateKey) {
            this.privateKey = privateKey;
            return this;
        }

        /**
         * Builds JWT object using private attributes
         * @return returns JWT object
         */
        public JWT build() {
            return new JWT(this.algorithm, this.properties, this.privateKey);
        }
    }
}