package ch01

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"crypto/rsa"
	"crypto/sha256"
	"fmt"
	"io"
	"log"
	"net"
	"net/http"
)

/********************************************************************************/

// Connect to a server directly using TCP in port 80.

func tcpConnect() {
	conn, err := net.Dial("tcp", "golang.org:80")
	if err != nil {
		log.Fatal(err)
	}
	defer conn.Close()

	fmt.Println("Connected to golang.org:80")
}

/********************************************************************************/

// Make an HTTP GET request to a server.

func httpGet() {
	resp, err := http.Get("https://andredsferreira.github.io/andre-kb/")
	if err != nil {
		log.Fatal(err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		log.Fatal(err)
	}
	// Print the first 500 bytes of the response body.
	fmt.Printf("Response body: %s\n", body[:500])
}

/********************************************************************************/

// Create a SHA-256 hash of a string.

func createSHA256Hash() {
	data := "Hello, World! My name is Andre."

	hash := sha256.Sum256([]byte(data))
	hashString := fmt.Sprintf("%x", hash)

	fmt.Printf("SHA-256 hash: %s\n", hash)
	fmt.Printf("SHA-256 hash string: %s\n", hashString)
}

/********************************************************************************/

// Showcasing AES-256 symmetric encryption and decryption.

func aesSymmetricEncryption() {
	key := make([]byte, 32)
	if _, err := rand.Read(key); err != nil {
		log.Fatal(err)
	}

	data := []byte("This is the data to be encrypted.")

	block, err := aes.NewCipher(key)
	if err != nil {
		log.Fatal(err)
	}
	gcm, err := cipher.NewGCM(block)
	if err != nil {
		log.Fatal(err)
	}

	nonce := make([]byte, gcm.NonceSize())
	if _, err := rand.Read(nonce); err != nil {
		log.Fatal(err)
	}

	ciphertext := gcm.Seal(nil, nonce, data, nil)
	fmt.Printf("Ciphertext: %x\n", ciphertext)

	plaintext, err := gcm.Open(nil, nonce, ciphertext, nil)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("Decrypted plaintext: %s\n", plaintext)
}

/********************************************************************************/

// Showcasing RSA-2048 asymmetric encryption and decryption.

func rsaAsymmetricEncryption() {
	privKey, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		log.Fatal(err)
	}
	pubKey := &privKey.PublicKey

	data := []byte("This is the data to be encrypted.")

	ciphertext, err := rsa.EncryptOAEP(sha256.New(), rand.Reader, pubKey, data, nil)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("Ciphertext: %x\n", ciphertext)

	plaintext, err := rsa.DecryptOAEP(sha256.New(), rand.Reader, privKey, ciphertext, nil)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("Decrypted plaintext: %s\n", plaintext)
}

/********************************************************************************/
