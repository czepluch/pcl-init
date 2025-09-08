# Credible Layer Minimal Example - A Great Starting Point

This repository is a minimal Credible Layer example focused solely on the Ownable contract and its corresponding assertion. Use it as a lightweight starting point to build, test, store, and submit assertions.

## Prerequisites

- Phylax Credible CLI (`pcl`)
  - macOS (Homebrew):

    ```bash
    brew tap phylaxsystems/pcl
    brew install phylax
    ```

  - Alternatively (any OS, via cargo):

    ```bash
    cargo +nightly install --git https://github.com/phylaxsystems/credible-sdk --locked pcl
    ```

  - See the installation guide for more options: <https://docs.phylax.systems/credible/credible-install>

- Foundry: <https://getfoundry.sh/>

## Clone and Setup

This repo uses git submodules. Clone with submodules:

```bash
git clone --recurse-submodules https://github.com/czepluch/pcl-init.git
cd pcl-init
```

If you already cloned without submodules, initialize them with:

```bash
git submodule update --init --recursive
```

The project includes:

- `credible-std`: Core Credible Layer functionality
- `forge-std`: Forge standard library used in tests
- `openzeppelin-contracts`: OpenZeppelin contracts

## Project Contents (minimal)

- `src/Ownable.sol`: Example Ownable contract
- `assertions/src/OwnableAssertion.a.sol`: Assertion that prevents ownership changes
- `assertions/test/OwnableAssertion.t.sol`: Test for the Ownable assertion
- `script/DeployOwnable.s.sol`: Script to deploy the Ownable contract
- `.github/workflows/ci.yml`: CI kept intact

## Build and Test

Use the `assertions` profile with `pcl`:

```bash
FOUNDRY_PROFILE=assertions pcl build
FOUNDRY_PROFILE=assertions pcl test
```

This runs the tests in `assertions/test`.

## Authenticate and Create a Project

```bash
pcl auth login
```

After authenticating in the browser, create a project in the dapp and specify the protected contract(s).

## Store the Assertion

Store the Ownable assertion:

```bash
pcl store OwnableAssertion
```

All assertions here use `ph.getAssertionAdopter` to resolve the protected contract without requiring it in the constructor.

## Submit the Assertion

Submit all prepared assertions interactively:

```bash
pcl submit
```

Or submit specifically:

```bash
pcl submit -a OwnableAssertion -p <project-name>
```

## Activate the Assertion

In the dapp, open your project, review the assertion marked "Ready for Review," and activate it by signing the transaction. Once active, the contract is protected.

## Deploy Ownable

Note: You can set environment variables and reference them in commands.

```bash
# Set environment variables
export PRIVATE_KEY=0x...      # Your private key with 0x prefix
export DEPLOYER_ADDRESS=0x... # Your deployer address
export RPC_URL=phylax_demo_rpc_url

# Deploy the contract
forge script script/DeployOwnable.s.sol \
  --rpc-url $RPC_URL \
  --sender $DEPLOYER_ADDRESS \
  --private-key $PRIVATE_KEY \
  --broadcast
```

## Basic Interactions (example)

```bash
# Check the current owner
cast call $OWNABLE_ADDRESS "owner()" --rpc-url $RPC_URL

# Attempt to transfer ownership (should be prevented by the assertion)
cast send $OWNABLE_ADDRESS "transferOwnership(address)" 0x1234567890123456789012345678901234567890 \
  --private-key $PRIVATE_KEY \
  --rpc-url $RPC_URL \
  --timeout 20

# Verify the owner did not change
cast call $OWNABLE_ADDRESS "owner()" --rpc-url $RPC_URL
```

## Cursor Rules for Assertions (optional)

This repository includes a Cursor rules file (`.cursor/rules/phylax-assertions.mdc`) to assist with assertion development in `assertions/`. You can reference the rules by typing `@phylax-assertions` in Cursor.

## Additional Resources

- Quickstart: <https://docs.phylax.systems/credible/pcl-quickstart>
- Assertions Book: <https://docs.phylax.systems/assertions-book/assertions-book-intro>
