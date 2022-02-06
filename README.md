# Address Validation

## Instructions

### Prerequisites

#### Clone the repository

If you want to use ssh and have not already enabled it, follow these [instructions](https://docs.github.com/en/authentication/connecting-to-github-with-ssh).
Then, open a terminal, navigate to the directory of your choice, and type:

```bash
git clone git@github.com:vancourtj/address_validation.git
```
#### rbenv

Make sure you have rbenv installed. In the same terminal you can type:

```bash
rbenv -v
```

If you do not have rbenv installed, follow these [instructions](https://github.com/rbenv/rbenv#installation).

#### Ruby

This project was written in Ruby [3.1.0](https://www.ruby-lang.org/en/news/2021/12/25/ruby-3-1-0-released).

You can check your Ruby installation in the same terminal:

```bash
ruby -v
```

If you do not have ruby installed or the correct version:

```bash
rbenv install 3.1.0
rbenv local 3.1.0
```

#### Bundler

Make sure you have bundler installed. In the same terminal you can type:

```bash
bundler -v
```

If you do not have bundler installed, use this command:

```bash
gem install bundler
```

You can read more about bundler [here](https://bundler.io/).

Then, install the gems for this project:

```bash
bundle install
```

### API Key

You can set the API Key in `.env` by replacing `ADDRESS_VALIDATOR_API_KEY="myAPIKey"` with `ADDRESS_VALIDATOR_API_KEY="<actual_key>"`.

The script will run as is, but will get an `API_KEY_INVALID_OR_DEPLETED` response from the API.

Alternatively, you can get your own key [here](https://www.address-validator.net/free-trial-registration.html).

### Script

With everything installed, you can run the script from the project directory with:

```bash
bundle exec ruby scripts/address_validation.rb --csv_file_name spec/support/correctly_formatted.csv
```

This will run it with a valid csv from the spec support section. You could run the script with any csv by replacing `spec/support/correctly_formatted.csv` with the file path of your choice.

### Tests

With everything installed, you can run the entire test suite from the project directory with:

```bash
bundle exec rspec
```

You can also run individual spec files from the project directory. For example:

```bash
bundle exec rspec spec/lib/gateway_spec.rb
```

## Design Choices

### Script

The script file interacts with the command line (takes in arguments and prints to terminal)
and loads the environment variables early in code execution. All other responsibilities get handed
off to different services. This provides a command-line program
and extendability of the underlying code. If this integration were to be implemented in a rails application,
then removing the script wouldn't require massive code changes.

The script will cache the valid address responses to avoid API key/rate depletion. It would be
reasonable to cache the invalid requests too while the only use case is a script as the probability
that an address goes from invalid to valid during a single run is near zero. In a scenario where the
integration is being used as a gem in a rails application, it would make sense to explore adding
database models and tables for the valid addresses.

### Services

#### CLI and CSV

These input parsing operations were abstracted out of the script and into their own services to ease expanding
functionality and testing. It also made implementing controls on the command line input and csv layout
straightforward:

- the script will only run when the provided a `csv_file_name`
- the csv has to have data
- the csv can not have too many rows to prevent nefarious parties from depleting the API Key
- the csv has to have all of the columns listed in the problem statement
- each row of the csv must have data for each field

You can change the maximum row count by setting `MAXIMUN_ADDRESS_CHECKS` in `.env`. I wanted to put constants related
to the API in `.env` for easy configuration of the integration. The `USAGE` and `PERMITTED_COLUMNS` constants are with
their respective services to separate what would become part of an integration gem from the input parsing.

#### Address Validation

This service is a layer that interacts with the gateway for the API. The implementation here is simple,
but future work may require more complicated operations on the address data to be consumed downstream. Those changes
may have nothing to do with the gateway. In other rails applications I've worked in, they used the pattern
of creating a gem for each integration where the service layer is part of the application and the gateway
is in the gem creating a clear system boundary.

#### Address Printing

This is another abstraction that removes pretty printing responsibility from the script and puts it into a flexible,
testable service. There is some logic to format the API response based on if there is a valid address coming back
or some form of invalid/error message.

### Lib (or the actual API integration)

This is a gateway-communicator pattern that provides a simple interface to the API for the codebase through the gateway
and isolates the real API interactions in the communicator.

The gateway is configurable with `ADDRESS_VALIDATOR_GATEWAY_STRATEGY` in `.env`. Setting the strategy to `REAL` will
allow the script to hit the real API endpoint. Setting the envvar to `FAKE` will make sure the script does not use
the API endpoint and instead the fake gateway mimics the expected communicator response with a fixed data set.

The address validator api doc provides a sample url and lists the optional params:

```
https://api.address-validator.net/api/verify?StreetAddress=Heilsbronner%20Str.%204&City=Neuendettelsau&PostalCode=91564&CountryCode=de&Geocoding=true&APIKey=your API key
```

The communicator will take in the street address, city, and postal code for one address and then:
- build a url following the provided pattern using the minimum params
- make a get network request
- parse and format the response into a friendly struct
- return the formatted response

The real gateway creates a new communicator instance with a given API Key and base url. That means the only assumption
carried forward for the gateway is that any additional address validator endpoints we would interact with would require
an API Key and base url. Any changes to the original network request, say enabling Geocoding, would only require code
changes to the communicator and anything downstream that cares about Geocoding. That seems like a safe assumption.

I placed the API Key and base url in `.env` to make these easily configurable.

## API Testing

Due to the limited usage of the API Key, I wanted a way to store some sample responses for cases I knew the address
would be valid and invalid - these sample responses could serve as a reference during development and be reusable
during testing. That's why I used the [VCR gem](https://github.com/vcr/vcr) in the relevant specs to only make a
real API request once. Each subsequent spec run will fake the call and return the tagged cassette. The gem also
let me filter my API Key from the url.

In the scenario where this integration becomes part of a real application, having `VCR` will provide stable tests
for the current usage and whatever additional API requests that get added.