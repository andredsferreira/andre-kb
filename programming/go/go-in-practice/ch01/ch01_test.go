package ch01

import (
	"testing"
)

func Test_tcpConnect(t *testing.T) {
	tcpConnect()
}

func Test_httpGet(t *testing.T) {
	httpGet()
}

func Test_createSHA256Hash(t *testing.T) {
	createSHA256Hash()
}

func Test_aesSymmetricEncryption(t *testing.T) {
	aesSymmetricEncryption()
}

func Test_rsaAsymmetricEncryption(t *testing.T) {
	rsaAsymmetricEncryption()
}

func Test_countingConcurrently(t *testing.T) {
	countingConcurrently()
}

func Test_passingNumbersConcurrently(t *testing.T) {
	passingNumbersConcurrently()
}

