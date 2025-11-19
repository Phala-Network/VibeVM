# VibeVM 🚀

<div align="center">

```
██╗   ██╗██╗██████╗ ███████╗██╗   ██╗███╗   ███╗
██║   ██║██║██╔══██╗██╔════╝██║   ██║████╗ ████║
██║   ██║██║██████╔╝█████╗  ██║   ██║██╔████╔██║
╚██╗ ██╔╝██║██╔══██╗██╔══╝  ╚██╗ ██╔╝██║╚██╔╝██║
 ╚████╔╝ ██║██████╔╝███████╗ ╚████╔╝ ██║ ╚═╝ ██║
  ╚═══╝  ╚═╝╚═════╝ ╚══════╝  ╚═══╝  ╚═╝     ╚═╝
```

**Good Vibes, Zero Trust Required**

*Powered by [Phala Cloud](https://phala.com) x [dstack](https://github.com/dstack-tee/dstack)*

</div>


[![](https://cloud.phala.network/deploy-button.svg)](https://cloud.phala.network/templates/VibeVM)

## Overview

VibeVM is a secure, lightweight development environment running in a Confidential VM (CVM) on [Phala Cloud](https://phala.com).

## Quickstart

To launch in a CVM on Phala Cloud from the CLI (requires [Phala Cloud API Key](https://cloud.phala.network/dashboard/tokens)), clone this repo or launch the template in the [Phala Cloud Templates](https://cloud.phala.network/templates/VibeVM) dashboard.

```
# Clone the github repo
git clone https://github.com/Phala-Network/VibeVM.git
cd VibeVM
# Edit .env file for your environment
cp .env.example .env
# Get your Phala Cloud API key at https://cloud.phala.network/dashboard/tokens
export PHALA_CLOUD_API_KEY=sk-sasdf
phala deploy -e .env --vcpu 4 --memory 8192 --disk-size 80 docker-compose.yaml
```

Example CLI Output
```
Deploying CVM vibevm...

CVM created successfully!

CVM ID:    0ae6f811-35a8-4183-a229-93bccb264403
Name:      vibevm
App ID:    9c4e3f6bda4ab645d784109e5b0d192654d30f5a
Dashboard URL:  https://cloud.phala.network/dashboard/cvms/0ae6f811-35a8-4183-a229-93bccb264403
```

### cURL: Direct API Access

```bash
# Execute shell command
curl -X POST http://localhost:8080/v1/shell/exec \
  -H "Content-Type: application/json" \
  -d '{"command": "echo Hello from VibeVM && pwd"}'

# Get sandbox environment info
curl http://localhost:8080/v1/sandbox

# Take browser screenshot
curl -X POST http://localhost:8080/v1/browser/screenshot \
  -o screenshot.png

# Read a file
curl -X POST http://localhost:8080/v1/file/read \
  -H "Content-Type: application/json" \
  -d '{"file": "/home/gem/.bashrc"}' | jq .

# Get TEE information
curl --unix-socket /var/run/dstack.sock \
  http://localhost/info | jq .

# Derive a key in TEE
curl --unix-socket /var/run/dstack.sock \
  -X POST http://localhost/prpc/DeriveKey \
  -H "Content-Type: application/json" \
  -d '{"path": "/my-app/key"}' | jq .
```
---

## Support & Community

- 🐛 [Report Issues](https://github.com/Phala-Network/VibeVM/issues)
- 💬 [Community Discussions](https://github.com/Phala-Network/VibeVM/discussions)
- 📧 [Phala Support](https://discord.gg/phala-network)
- 📚 [Phala Documentation](https://docs.phala.com)

## Related Projects

- 🔒 [Dstack TEE](https://github.com/Dstack-TEE/dstack) - Trusted Execution Environment SDK
- 🌐 [Phala Cloud](https://github.com/Phala-Network/phala-cloud) - Private Compute Cloud Service to Host dstack CVMs

## Contributing

We welcome contributions! If you've built something cool with VibeVM or have improvements to suggest:

1. Fork this repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

<div align="center">

[🚀 Sign up for Phala Cloud](https://phala.com) • [📖 Read the Docs](https://docs.phala.com) • [⭐ Star on GitHub](https://github.com/phala-network/VibeVM)

Built with ❤️ by the Phala Network community

**Powered by [Dstack TEE](https://github.com/Dstack-TEE/dstack)

</div>
