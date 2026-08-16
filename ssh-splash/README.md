# SSH-Splash
![alt text](/images/screenshot1.jpg)

I'd like to thank [roshan0099](https://github.com/roshan0099) for this idea.
This was a fun little project that adds a custom splash screen when you ssh into your server.

### Step 1. Install figlet and lm-sensors:

  -On Ubuntu/Debian:
```bash
sudo apt install figlet lm-sensors
```
  -On Fedora/RHEL:
```bash
sudo dnf install figlet lm_sensors
```

## Step 2. Create the sh file and give it permissions
  -Create the splash config file
```bash
sudo vim /etc/profile.d/99-splash.sh
```
  -Copy/Paste [99-splash.sh](./99-splash.sh) in your server
  -Give it the proper permissions
```bash
sudo chmod +x /etc/profile.d/99-splash.sh
```

 -Have fun playing around with all of the options, I added a custom randon quote api at the bottom.