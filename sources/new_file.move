module CertificateVerification::simple_certificate {
    use std::string::String;
    use aptos_framework::signer;
    use aptos_framework::timestamp;
    use std::vector;

    // Error codes
    const E_CERTIFICATE_EXISTS: u64 = 1;
    const E_CERTIFICATE_NOT_FOUND: u64 = 2;

    /// Struct representing a certificate
    struct Certificate has store {
        id: String,
        recipient: address,
        issuer: address,
        issue_date: u64,
        is_valid: bool
    }

    /// Resource to store certificates
    struct CertificateStore has key {
        certificates: vector<Certificate>
    }

    /// Function to initialize certificate store for an issuer
    public fun initialize_store(issuer: &signer) {
        let store = CertificateStore {
            certificates: vector::empty()
        };
        move_to(issuer, store);
    }

    /// Function to issue a new certificate
    public fun issue_certificate(
        issuer: &signer,
        recipient: address,
        cert_id: String
    ) acquires CertificateStore {
        let issuer_addr = signer::address_of(issuer);
        let store = borrow_global_mut<CertificateStore>(issuer_addr);
        
        let certificate = Certificate {
            id: cert_id,
            recipient,
            issuer: issuer_addr,
            issue_date: timestamp::now_seconds(),
            is_valid: true
        };
        
        vector::push_back(&mut store.certificates, certificate);
    }

    /// Function to verify a certificate's validity
    public fun verify_certificate(issuer_addr: address, cert_id: String): bool acquires CertificateStore {
        let store = borrow_global<CertificateStore>(issuer_addr);
        let i = 0;
        let len = vector::length(&store.certificates);
        
        while (i < len) {
            let cert = vector::borrow(&store.certificates, i);
            if (cert.id == cert_id) {
                return cert.is_valid
            };
            i = i + 1;
        };
        false
    }
}