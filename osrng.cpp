// osrng.cpp - written and placed in the public domain by Wei Dai

// Thanks to Leonard Janke for the suggestion for AutoSeededRandomPool.

#include "pch.h"

#ifndef CRYPTOPP_IMPORTS

#include "osrng.h"

#ifdef OS_RNG_AVAILABLE

#include "rng.h"

#ifdef CRYPTOPP_WIN32_AVAILABLE
#ifndef CRYPTOPP_WINRT
#ifndef _WIN32_WINNT
#define _WIN32_WINNT 0x0400
#endif
#endif //ndef CRYPTOPP_WINRT
#include <windows.h>
#ifndef CRYPTOPP_WINRT
#include <wincrypt.h>
#endif //ndef CRYPTOPP_WINRT
#endif

#ifdef CRYPTOPP_UNIX_AVAILABLE
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#endif

#ifdef CRYPTOPP_WINRT
//#using <Windows.winmd>
using namespace Windows::Security::Cryptography;
using namespace Windows::Storage::Streams;
#endif //CRYPTOPP_WINRT

NAMESPACE_BEGIN(CryptoPP)

#if defined(NONBLOCKING_RNG_AVAILABLE) || defined(BLOCKING_RNG_AVAILABLE)
OS_RNG_Err::OS_RNG_Err(const std::string &operation)
	: Exception(OTHER_ERROR, "OS_Rng: " + operation + " operation failed with error " + 
#ifdef CRYPTOPP_WIN32_AVAILABLE
		"0x" + IntToString(GetLastError(), 16)
#else
		IntToString(errno)
#endif
		)
{
}
#endif

#ifdef NONBLOCKING_RNG_AVAILABLE

#ifdef CRYPTOPP_WIN32_AVAILABLE

MicrosoftCryptoProvider::MicrosoftCryptoProvider()
{
#ifndef CRYPTOPP_WINRT
	if(!CryptAcquireContext(&m_hProvider, 0, 0, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT))
		throw OS_RNG_Err("CryptAcquireContext");
#endif //ndef CRYPTOPP_WINRT
}

MicrosoftCryptoProvider::~MicrosoftCryptoProvider()
{
#ifndef CRYPTOPP_WINRT
  CryptReleaseContext(m_hProvider, 0);
#endif //ndef CRYPTOPP_WINRT
}

#endif

NonblockingRng::NonblockingRng()
{
#ifndef CRYPTOPP_WIN32_AVAILABLE
	m_fd = open("/dev/urandom",O_RDONLY);
	if (m_fd == -1)
		throw OS_RNG_Err("open /dev/urandom");
#endif
}

NonblockingRng::~NonblockingRng()
{
#ifndef CRYPTOPP_WIN32_AVAILABLE
	close(m_fd);
#endif
}

void NonblockingRng::GenerateBlock(byte *output, size_t size)
{
#ifdef CRYPTOPP_WIN32_AVAILABLE
#	ifdef WORKAROUND_MS_BUG_Q258000
		const MicrosoftCryptoProvider &m_Provider = Singleton<MicrosoftCryptoProvider>().Ref();
#	endif
#ifdef CRYPTOPP_WINRT
    auto buffer = CryptographicBuffer::GenerateRandom(size);

    Platform::Array<byte>^ bytes = nullptr;
    CryptographicBuffer::CopyToByteArray(buffer, &bytes);
    memcpy_s(output, size, bytes->Data, bytes->Length);
#else
	if (!CryptGenRandom(m_Provider.GetProviderHandle(), (DWORD)size, output))
		throw OS_RNG_Err("CryptGenRandom");
#endif //CRYPTOPP_WINRT
#else
	while (size)
	{
		ssize_t len = read(m_fd, output, size);

		if (len < 0)
		{
			// /dev/urandom reads CAN give EAGAIN errors! (maybe EINTR as well)
			if (errno != EINTR && errno != EAGAIN)
				throw OS_RNG_Err("read /dev/urandom");

			continue;
		}

		output += len;
		size -= len;
	}
#endif
}

#endif

// *************************************************************

#ifdef BLOCKING_RNG_AVAILABLE

#ifndef CRYPTOPP_BLOCKING_RNG_FILENAME
#ifdef __OpenBSD__
#define CRYPTOPP_BLOCKING_RNG_FILENAME "/dev/srandom"
#else
#define CRYPTOPP_BLOCKING_RNG_FILENAME "/dev/random"
#endif
#endif

BlockingRng::BlockingRng()
{
	m_fd = open(CRYPTOPP_BLOCKING_RNG_FILENAME,O_RDONLY);
	if (m_fd == -1)
		throw OS_RNG_Err("open " CRYPTOPP_BLOCKING_RNG_FILENAME);
}

BlockingRng::~BlockingRng()
{
	close(m_fd);
}

void BlockingRng::GenerateBlock(byte *output, size_t size)
{
	while (size)
	{
		// on some systems /dev/random will block until all bytes
		// are available, on others it returns immediately
		ssize_t len = read(m_fd, output, size);
		if (len < 0)
		{
			// /dev/random reads CAN give EAGAIN errors! (maybe EINTR as well)
			if (errno != EINTR && errno != EAGAIN)
				throw OS_RNG_Err("read " CRYPTOPP_BLOCKING_RNG_FILENAME);

			continue;
		}

		size -= len;
		output += len;
		if (size)
			sleep(1);
	}
}

#endif

// *************************************************************

void OS_GenerateRandomBlock(bool blocking, byte *output, size_t size)
{
#ifdef NONBLOCKING_RNG_AVAILABLE
	if (blocking)
#endif
	{
#ifdef BLOCKING_RNG_AVAILABLE
		BlockingRng rng;
		rng.GenerateBlock(output, size);
#endif
	}

#ifdef BLOCKING_RNG_AVAILABLE
	if (!blocking)
#endif
	{
#ifdef NONBLOCKING_RNG_AVAILABLE
		NonblockingRng rng;
		rng.GenerateBlock(output, size);
#endif
	}
}

void AutoSeededRandomPool::Reseed(bool blocking, unsigned int seedSize)
{
	SecByteBlock seed(seedSize);
	OS_GenerateRandomBlock(blocking, seed, seedSize);
	IncorporateEntropy(seed, seedSize);
}

NAMESPACE_END

#endif

#endif
