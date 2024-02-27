# README

This is a monolithic application with Action Mailbox and SendGrid integration.

This application will allow us to route the incoming emails to controllers-like for processing.

The inbound emails are turned into Inbound Email records using Active Record and feature lifecycle tracking and storage of the original email on cloud storage via Active Storage.


### Step 1: Setup action mailbox

```sh
 $ bin/rails action_mailbox:install
 $ bin/rails db:migrate

```


### Step 2: Ingress Configuration

```ruby
# config/environments/development.rb || config/environments/production.rb
config.action_mailbox.ingress = :sendgrid
config.hosts << 'yoursite.com'

```


### Step 3: Generate Password for authenticating requests and set the credentials

Generate a secure password

```sh
    rails c
    SecureRandom.alphanumeric
    # => "Hng7pRE9K5ztqZMI"
```

After that, add that password to your application’s encrypted as follows.

 ```sh
    EDITOR="vim" bin/rails credentials:edit
 ```

 ```ruby
 action_mailbox:
  ingress_password: <GENERATED_PASSWORD>

 ```

### Step 4: Setup a mailbox

Generate the mailbox controller where emails will be processed

```ruby
# Generate new mailbox
$ bin/rails generate mailbox forwards
```

```ruby
  # app/mailboxes/forwards_mailbox.rb
  class ForwardsMailbox < ApplicationMailbox
    # Callbacks specify prerequisites to processing

    def process
      # process the emails
      #  puts "From: #{mail.from}"
      #  puts "To: #{mail.to}"
      #  puts "Body: #{mail.body}"

      # do stuff
    end
  end
```

### Step 5: Configure basic routing
Configuring our application_mailbox to accept all incoming emails

```ruby
# app/mailboxes/application_mailbox.rb
class ApplicationMailbox < ActionMailbox::Base
  # Accept from any domains
  routing all: :forwards

  # Accept emails from an specific single email account
  # routing /info@email-domain.com/i => :forwards

  # Accept all emails from single domain
  #routing /.*@email-domain.com/i => :forwards

  # Accept email from multiple domains
  # routing /.*@primary-email-domain.com|.*@secondary-email-domain.com/i => :forwards
end
```

### Step 6: Test in development

There's a conductor controller mounted at /rails/conductor/action_mailbox/inbound_emails, which gives you an index of all the Inbound Emails in the system

Click on New inbound email by form. Fill in all required details like From, To, Subject and Body. You can leave other fields blank.

Before clicking on Deliver inbound email, let’s add byebug (or any other debugging breakpoint e.g. binding.pry)

```ruby
  # app/mailboxes/forwards_mailbox.rb
  class ForwardsMailbox < ApplicationMailbox
    def process
      byebug
    end
  end
```


### Step 8: Authenticate domain in SendGrid to test Live


Start by logging in to your SendGrid account. In the left-side navigation bar, click on “Settings” and then select Sender Authentication.

<img width="347" alt="p1-sendgrid-sidebar-sender-auth" src="https://github.com/bjohnmer/hermes/assets/1920466/41a26b3e-365c-4ac6-a052-011dc5db248b">


On the Sender Authentication page, click the “Get Started” button in the “Domain Authentication” section.

<img width="1127" alt="p2" src="https://github.com/bjohnmer/hermes/assets/1920466/d1dc85f1-456c-43f8-818a-d27fb5126ca7">


Here, in the first prompt, you need to select your DNS provider, which in most cases is the company from which you purchased the domain. Click on Next to continue

<img width="1377" alt="p3" src="https://github.com/bjohnmer/hermes/assets/1920466/b42e30d1-a4ad-4a4f-9ce8-5d6d3709594f">


On the next screen, you will be prompted to enter your domain name. In my case, I entered bjohnmer.com. You will need to enter your own domain name. Click on Next to continue

<img width="1279" alt="p4" src="https://github.com/bjohnmer/hermes/assets/1920466/cd7faef2-b09b-4bec-a348-3eb230bcc508">


SendGrid is now going to show you a list of DNS records that you will need to add to your domain. Each DNS record has a type, a host and a value. Don't close this page yet.

<img width="1374" alt="p5" src="https://github.com/bjohnmer/hermes/assets/1920466/398c1f12-9425-4c6d-9d5a-0363058c7ea2">


After that, you have to go into your domain provider’s administration page to add these DNS records. For this instance, I used Cloudflare.

So here we are going to add those DNS records. One tricky aspect here is figuring out that you need to remove the domain name from the hosts provided by SendGrid, as it's shown in the following:

<img width="1520" alt="p6" src="https://github.com/bjohnmer/hermes/assets/1920466/55ecab67-d502-4b32-b30d-aaa733d32509">


Additionally I've added an extra record MX.

Then, return to the DNS list on the Sender Authentication page. Click on the checkbox "I've added these records" and click on the 'Verify' button.

If all goes well, a successful view will be shown

<img width="1432" alt="p7" src="https://github.com/bjohnmer/hermes/assets/1920466/ea49dfae-6e29-4bf0-995e-a94f2cdfcc43">


### Step 9: Add a sender verification

Go back to the Sender Authentication page and click on the button 'Verify a Single Sender' in the Single Sender Verification section.

<img width="572" alt="ss-p1" src="https://github.com/bjohnmer/hermes/assets/1920466/219e2bb9-425e-4f48-944f-0f955f63bde0">


Click on the button 'Create new Sender' and fill the form.

<img width="669" alt="ss-p2" src="https://github.com/bjohnmer/hermes/assets/1920466/b829eca7-1b63-4128-98b9-5fb282b26b99">


After registering a single sender, it will receive an email to verify it. Click on 'Verify Single Sender' Button

<img width="637" alt="ss-p3" src="https://github.com/bjohnmer/hermes/assets/1920466/83de6bdb-8dec-4fe7-ad76-c2bc57fc35d5">


### Step 10: Configure the Inbound Parse

- In the left-side navigation bar, select Inbound Parse and click on 'Add Host & URL'.
![ip-p0](https://github.com/bjohnmer/hermes/assets/1920466/5529297b-6cff-4f86-bcbe-42ded4b33690)

<img width="1423" alt="ip-p1" src="https://github.com/bjohnmer/hermes/assets/1920466/e7ca269c-a59a-4446-88a1-0ec6ea52011c">

- You can add/leave the subdomain part as required. I have left it blank
- Under “Domain”, choose your domain name that you just verified
- Under the URL Destination we will need to build one and add it

  For example: 'https://actionmailbox:<GENERATED_PASSWORD>@<yoursite.com>/rails/action_mailbox/sendgrid/inbound_emails'
  
<img width="695" alt="ip-p2" src="https://github.com/bjohnmer/hermes/assets/1920466/d3e475dc-839c-4e3a-a831-cde9d28ab9ac">


### Step 10: Heroku domain
As I am using Heroku, I did some additional steps.

- I have to add my Cloudflare DNS to Namecheap in the custom DNS section. Then, I added the Heroku domain
to Cloudflare.


You can follow this tutorials:
- https://guides.rubyonrails.org/action_mailbox_basics.html#postfix
- https://prabinpoudel.com.np/articles/action-mailbox-with-sendgrid/
