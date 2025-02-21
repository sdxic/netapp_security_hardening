# NetApp Security Hardening

In this lab, you will implement a series of security best practices to harden a NetApp ONTAP environment. This lab focuses on data encryption and protection, network security, and user access controls. This lab caters to individuals with some prior NetApp experience.

## Lab Activities

* Part 1: Schedule and Access Your Lab
* Part 2: Data At Rest Encryption
* Part 3: SMB Storage Provisioning
* Part 4: NFS Storage Provisioning
* Part 5: Routine Storage Administrative Tasks

## Part 1: Schedule and Access Your Lab

1. Navigate to <https://catalog.cdwsdx.com/catalog.php?category_id=19> and select the NetApp Security Hardening lab.

2. You will need to login to schedule the lab.  If you don't have an account you can create one by selecting the `Sign up` link at the bottom of the login box.
![okta_login](images/okta_login.png)

3. Access the lab by following the instructions that were emailed to you.

## Part 2: Data at rest encryption

1. On the lab jumpbox, launch the NTAP shortcut.  This shortcut will take you to the NetApp System Manager web interface.
![System Manager Shortcut](images/part2_step1a.png)

2. You will get a "Your connection is not private" message, select advanced and then click Proceed.
![SSL](images/part2_step2a.png)

3. Input your credentials and click Sign In.
    * Username - admin
    * Password - Use the password listed within the my labs section.

4. Upon successful login you will be directed to the System Manager Dashboard.  The Dashboard provides a overview of the cluster's overall health and configuration.  You will notice the controller model, in this case it's virtual, capacity, system performance and network details.  Currently these panels don't contain any information as we haven't configured anything.
![System Manager Dashboard](images/part2_step4a.png)

5. One of the first tasks we will perform is Preparing Storage.  When we prepare the storage it is going to create aggregates/local tiers.  We will store virtual machine and user data in the local tiers.
      * A) Select Prepare Storage from the dashboard.
      * B) Within the Prepare Storage screen it will ask if you want to enable software encryption. Software encryption ensures your data is stored encrypted at rest.  When we configure software encryption we can apply it at a volume and or aggregate/tier level.  For most use cases you are going to apply it to the aggregate/tier. By applying at the aggregate/tier level you ensure that storage efficiencies aren't lost.
      * C) You will need to generate a random 32 character passphrase. You can generate a random phrase by opening a new tab in Chrome and going to <https://www.keepersecurity.com/features/passphrase-generator/>.  Change the words to 8 and then copy the passphrase.
      ![Create PassPhrase](images/part2_step5c.png)
      * D) With the passphrase copied to your clipboard go back to the NetApp System Manager tab and paste that passphrase in the configure key manager section under onboard key manager and click prepare storage.
      ![Prepare Storage](images/part2_step5d.png)
      * C) You will be redirected to the dashboard and you should be able to see available capacity in the capacity panel.
      ![Capacity Panel](images/part2_step5e.png)
      * F) Let's validate that our aggregate/tier is configured with encryption. Within system manager navigate to storage / tiers.  Click on the tier that's listed to get more details, validate that encryption status shows enabled.
      ![Encryption Status](images/part2_step5f.png)

## Part 3: System Manager Hardening

1. From within the System Manager interface navigate to Insights on the lefthand side. You will see a few action item cards within this screen.
![Action Items](images/part3_step1a.png)

2. Let's configure a login banner message when people attempt to access the cluster. Hover over the login banner card and select Fix It. You will be prompted to input a Login banner message. You can place anything you want in here, select apply to cluster login and then click enable.
![Login Banner](images/part3_step1b.png)

3. Let's configure our NTP servers. The recommendation is to have at least 3 NTP servers so that we have redundancy and accuracy. For this lab there is already one NTP server configured for you.  We will add two other NTP servers to this list. While this is acceptable for this lab you would want to confirm NTP servers in your environment.
![NTP Servers](images/part3_step1c.png)

4. Let's enable FIPS 140-2 compliance. By enabling FIPS 140-2 we ensure that SSL communication to system manager occurs with secure TLS versions.

      ![NTP Servers](images/part3_step1d.png)

5. We are not going to configure cluster notifications in the lab.  If this was a production environment we would want to ensure a syslog or SMTP server was configured for alerts.

6. Let's generate and configure a certificate from our internal certificate authority.  We are doing this to ensure the HTTPS communication with the cluster is valid and secure.
      * A) We will need to generate a certificate signing request from the ONTAP cluster to import into our certificate authority.  Navigate to Cluster / Settings and then click on certificates under Security. At the top of the certificates menu you should see a Generate CSR button, click on that button.
      ![Generate CSR](images/part3_step6a.png)
      * B) Under generate certificate signing request put in the following.
        * Subject Name - ntap-cl
        * Country - United States
        * Organization - CDWLABS
        * Organizational unit - CDWLABS
      ![Cert Basic](images/part3_step6b.png)
        * Select the More options button as we need to define further settings.
        * Scroll down to the bottom where it shows Subject Alternative Names (SAN) and click add.  Under DNS server you will put in the DNS name of the system manager interface. You can get this name from the URL in your browser. Select Generate
      ![Cert More Options](images/part3_step6b2.png)
        * Once the request is generated you will select Export to file.  You might get a pop-up on your browser asking to approve multiple file downloads.  Select allow as we will need both the certificate signing request and private key. Once the files are downloaded you can close the certificate signing request window by clicking close.  Verify the files downloaded by opening File Explorer and looking in the downloads directory. Make sure you have a file called csr.pem and privateKey.pem.  You will select the csr.pem file and copy it.
      ![Cert creation](images/part3_step6b3.png)
      ![Copy File](images/part3_step6b4.png)
      * C) Now we will need to login to our certificate authority, copy the certificate and sign the request to generate the certificate. CClick within Type here to Search on the bottom left of your desktop window. Type mstsc in the search box and then click on the Remote Desktop Connection application
      ![Remote Dekstop](images/part3_step6c.png)
      * D) In the Remote Desktop Connection window you will need to put in the IP address for your certificate authority server.  The IP address will be the lab subnet found under My Labs on the SDx Labs site with a .100 at the end, e.g. 10.242.243.100. Select the connect button.
      ![Cert Connection](images/part3_step6d.png)
      * E) You will be prompted for credentials. Input the following credentials and then select ok.
        * Username - Administrator
        * Password - Use the password listed within the my labs section
      ![Cert Connection](images/part3_step6e.png)
      * F) Once you are logged into the certificate authority server select Yes to allow your PC to be discoverable if prompted and close the Server Manager dashboard. You will need to paste the csr file you copied in step 6B to the desktop, ctrl+v.
      * G) Now we will need to process the certificate request.  On the certificate authority server you will need to open a command prompt and run the following command. certreq -attrib "CertificateTemplate:WebServer" a popup should appear asking you for the CSR file, select the file you copied over to the desktop. You will need to change the file type to all files in the bottom righthand side of the popup and click Open. Select the only available certification authority and click ok. On the Save Certificate popup put a filename of NetApp in and select save.
      ![Cert Creation](images/part3_step6g.png)
      ![Cert Creation](images/part3_step6g1.png)
      ![Cert Creation](images/part3_step6g2.png)
      * H) Now we need to export the root certificate authority cert to import in the NetApp along with the NetApp cert you saved in step G. On the certification server click within Type here to Search on the bottom left of your desktop window, type certification authority and then click on the Certification Authority application. Right click on the server name and select properties. Under the general tab select view certificate, click on the details tab of that certificate and select copy to file. Select next on the export wizard, select Base-64 encoded x.509 and select next.  In the file to export screen select browse, select your desktop and then put in ca_cert for the file name and click save, click next and finish. You should get a popup stating the export was successful. Click ok and then close the certification windows.
      ![Cert Creation](images/part3_step6h.png)
      ![Cert Creation](images/part3_step6h1.png)
      ![Cert Creation](images/part3_step6h2.png)
      ![Cert Creation](images/part3_step6h3.png)
      ![Cert Creation](images/part3_step6h4.png)
      * I) Now we will copy the certs and install them.
        * On the certification authority server we will need to navigate to the desktop and copy both the NetApp and ca_cert files we created.  
        ![Copy Certs](images/part3_step6i.png)
        * Once those are copied we will minimize the remote desktop window and paste the files in our downloads directory.
        ![Paste Certs](images/part3_step6i1.png)
        * Now open up the NetApp System Manager webpage, you should still be in the Certificates section.  Select Add under trusted certificate authorities and give the name lab-cert-authority and the same common name.  Select import under the certificate details, on the popup select your downloads folder and select the ca_cert file you copied over. It will populate the certificate details and then you can click on add.
        ![Cert install](images/part3_step6i2.png)
        * Under Certificates select the client/server tab. Select the add button, populate the certificate name and common name with ntap-cl. Under the certificate details click import and select the NetApp key you copied over from the certification server and click open. Under the private key select import and select the priveKey.pem file you exported from the NetApp, click open and then select the save button.
        ![Cert install](images/part3_step6i3.png)
        * J) Next we will need to configure the NetApp to use the new certificate we installed.  Click within Type here to search on the bottom left and type putty.  Click on the putty icon and type in ntap-cl and hit open. Accept the host key when the security popup opens. Login with the following information
            * Username - admin
            * Password - Use the password listed within the my labs section
        ![Cert Configure](images/part3_step6j.png)
        ![Cert Configure](images/part3_step6j1.png)
        * We will need to modify the certificate the cluster management interface is using.
        * Issue the next command, you will need to change your vserver, ca, and serial.  If you try and tab complete this, it will populate with incorrect information.  If you delete this information and hit tab again, it usually resolves this issue.  You can find the correct serial number in System Manager within Cluster, Settings, then under Security select Certificates and select Client/server certificates.  The correct ca is without -ntap at the end.
            * ssl modify -vserver lab242-243-ntap -ca lab242-243.lab -serial 4A000000044900AF3626173072000000000004 -common-name ntap-cl -server-enabled true
        ![Cert Modify](images/part3_step6j2.png)
        * Now that we have the certificate installed on the NetApp close your Chrome browser. Once it's closed click on the NTAP desktop shortcut and verify that the certificate is valid. Also notice our login banner.
        ![Cert Validation](images/part3_step6j3.png)

## Part 4: User security and verification

1. Lets create a new admin account, lock the default admin account and enable SSH security. By locking the default admin account we remove a well-known account that could be targeted.
      * A) From within system manager click on cluster / settings, scroll down to security and select users and roles.
        * Under users click the Add button
        * Leave the target product System Manager
        * For the username type in cdwlabs
        * For the role leave the default admin role selected
        * Under applications select add and make sure the following applications are listed with the authentication type of password.
        ![Create User](images/part4_step1a.png)
        * For the password use the password listed within the my labs section and then hit save
      * B) In the top right of the system manager page select the user icon and sign out
        ![Sign Out](images/part4_step1b.png)
        * Login using the new user account you created in step 4A.
        * Make sure you are still in Cluster / Settings / Security and users and roles
        * If you click on the 3 dots next to admin user you can select lock it.  Confirm the lock user dialog box.
        ![Admin lock](images/part4_step1b1.png)
        ![Admin lock](images/part4_step1b2.png)
      * C) Let's add a second authentication method for our new user to login via SSH.
        * Click within Type here to Search on the bottom left and type in putty.  Click on the putty icon and type in ntap-cl and hit open. Accept the host key when the security popup opens. Login with the following information
            * Username - cdwlabs
            * Password - Use the password listed within the my labs section
        * Click within Type here to Search on the bottom left and type in puttygen
        * In the Putty Key Generator window change the parameters from RSA to ECDSA and then click Generate.  Move your mouse cursor around the screen to generate the key. Click save private key.
        * It will ask if you want to save the key without a passphrase, select yes. Save this file on your desktop and label it private_key. Make sure to keep your Putty Key Generator open as you will need the public key in the next step.
        ![Private Key](images/part4_step1c.png)
        * Go back to your putty SSH session to the NetApp. 
        * Run the following command to configure a second authentication SSH authentication method for the cdwlabs user.
          * security login modify -user-or-group-name cdwlabs -application ssh -authentication-method password -second-authentication-method publickey
        * Run the following command to define a public key for the cdwlabs user.
        * When you copy your key from puttygen make sure to not select ecdsa-key-20241230 at the end.
          * security login publickey create -username cdwlabs -application ssh -index 0 -publickey "Paste your puttygen public key here, make sure you have open and close double quotes"
        ![Private Key](images/part4_step1c1.png)
        * Click within Type here to Search on the bottom left and type in putty.  Click on the putty icon and type in ntap-cl and hit open. Try to login using the cdwlabs user, you should get an error message stating No supported authentication methods available since we didn't send our private key.
        * Click within Type here to Search on the bottom left and type in putty.  Click on the putty icon and type in ntap-cl. Before selecting open go to the left side and expand Connection / SSH / Auth and select Credentials. Select browse for the private key file for authentication and select the private_key that you saved on your desktop. Now you can select open.
        
          ![Private Key](images/part4_step1c2.png)
        * Login with the following information
            * Username - cdwlabs
            * Password - Use the password listed within the my labs section
        * Notice that you can login since you provided the private key.
        ![Private Key](images/part4_step1c3.png)
2. Lets create another user and turn on multi-admin verification. Multi-admin verification ensures that critical administrative actions are authorized and reviewed by multiple administrators before an action is executed.
      * A) From within system manager click on cluster / settings, scroll down to security and select users and roles.
        * Under users click the Add button
        * Leave the target product System Manager
        * For the username type in mav1
        * For the role leave the default admin role selected
        * For the User login methods change the application of console to HTTP
        * For the password use the password listed within the my labs section and then hit save
        ![Create User](images/part4_step2a.png)
      * B) From within system manager click on cluster / settings, scroll down to security and select Multi-admin approval.
        * Create a approval group by clicking add
        * Give the approval group a name of admins
        * Select the cdwlabs and mav1 account in the approvers list
        * Don't populate an email address as there isn't a mail server available for this lab
        * Select the checkbox to make this the Default group
        ![MAV Group](images/part4_step2b.png)
        * Delete the default rules that are defined as we will create our own
        * Add a new rule by clicking add
        * Under operation select volume delete
        * Leave the query field blank
        * Under required approvers type in 1
        * Under approval groups select the admins approval group we created in the step above
        * Now create another rule for volume snapshot delete
        * Select the Enable button
        ![MAV Enable](images/part4_step2b1.png)
      * C) In order to test multi-admin verification we will need to create an Storage VM (SVM)
        * From within system manager click on storage and select Storage VMs
        * Click add
        * Give the Storage VM a name of cdwlabs
        * Select the checkbox to enable NFS
        * For now we are not going to allow NFS client access
        * Leave the default language to c.utf_8
        * Create a network interface. The IP address will be the lab subnet with a .62 at the end
        * Leave the subnet mask as 24
        * There's no need to add a gateway for this lab
        * Leave the Broadcast Domain and Port as Default
        * Select the save button
        ![SVM Create](images/part4_step2c.png)
        * With our SVM created we can now create a volume.  Select storage and then click volumes.
        * Click the Add button to create a new volume
        * Give the volume a name of nfs1 with a size of 20GiB and click save
        ![Volume Create](images/part4_step2c1.png)
        * Now let's try to delete the volume we just created
        * Click on the 3 dots next to nfs1 volume and select delete
        * Confirm you want to take the volume offline and delete the data by selecting the check boxes and then click delete
        * You should get an error in the top right corner stating the operation cannot be performed because the request was sent for approval. This is due to the multi-admin verification rules we setup earlier.
        ![Mav Approval](images/part4_step2c2.png)
        * Let's login as the other admin user we created and approve the request.
        * Open a Chrome incognito window and type in https://ntap-cl, it should auto populate the rest of the URL.
        * Accept the dialog box and login as the user we created in step 2A.
        * Once you are logged in go to Event & Jobs and select Multi-admin requests
        * Review the request and then select approve
        ![Approve Volume Delete](images/part4_step2c3.png)
        * Now that the request is approved switch back over to your non-incognito Chrome browser
        * Notice how the volume is still there? We will need to delete the volume again as the request has now been approved
        * Notice how the volume is deleted now?

## Part 5: SMB Setup and Anti-Ransomware

1. Lets enable the SMB protocol on the existing SVM we created earlier.
      * A) From within system manager click on Storage and then select Storage VMs
        * Click on the cdwlabs SVM
        * In the righthand window select settings
        * Under protocol click on the gear icon under SMB/CIFS
        * Administrator name - Administrator
        * Password - Use the password listed within the my labs section.
        * Server Name - cdwlabs
        * Active Directory Domain - You can get this from the URL in your system manager browser. After the ntap-cl you will see the domain name.
        ![Domain Name](images/part5_step1a.png)
        * Organizational Unit - Use the default CN=Computers
        * Domains - Leave the default domain that's in there, if there isn't one, copy the Active Directory Domain name from the previous step.  
        Name Servers - Leave the default that's in there, if there isn't one, it will be your lab subnet with a .100 at the end.
        * Select the checkbox to reuse the data interface used for the NFS or S3 protocol. Select the drop down and click on the interface we created earlier.
        * Select the save button.

          ![Setup SMB](images/part5_step1a1.png)
        * Now we are going to secure communication to the NetApp by enabling signing and encryption. On the SMB/CIFS card in the protocols section click on the arrow.
        * Click on edit SMB/CIFS settings
        * Select the checkboxes for signing required and encrypt data, click on save.
        ![SMB Encryption](images/part5_step1a2.png)

2. Lets configure a share and enable Anti-Ransomware. We will then simulate a ransomware attack.
      * A) From within system manager click on Storage and then select volumes.  Click on Add at the top left of the screen.
        * Give the volume a name of share
        * Give the volume a capacity size of 10GiB
        * Uncheck Export via NFS and leave share via SMB/CIFS checked.
        * Select save

        ![Volume Create](images/part5_step2a.png)
      * B) From within system manager click on Storage and then select volumes.
        * Open windows file explorer and explore the share you just created. To get the path to the share click on the volume name within system manager, within the overview section scroll down and copy the SMB/CIFS Access path. Paste that path within windows file explorer.
         ![Get Path](images/part5_step2b1.png)
      * C) Download 2 PowerShell scripts to create files and simulate an attack.
        * https://github.com/sdxic/netapp_security_hardening/blob/master/create%20files.ps1
        * https://github.com/sdxic/netapp_security_hardening/blob/master/encrypt%20files.ps1
        * Right click the create files PowerShell script and select run with PowerShell.  Type Y for yes if prompted about Execution Policy Change.  This will create files in the share you viewed in the previous step.  After the script completes browse the share and verify you can see files.
        * From within system manager click on Storage and then select volumes
        * Click on the volume we created before named share and then select the security tab.
        * Change the status of Anti-ransomware from disabled to enabled
        * Click the Event severity settings cogwheel. Change the Created a ransomware snapshot from don't generate to Notice, select save
         ![Anti-Ransomware](images/part5_step2b2.png)
        * Now we are going to encrypt the files that we just created.  Right click the encrypt files PowerShell script and select run with PowerShell.  This will encrypt and rename the files we just created.
        * Once the script completes view the contents of a file on that share. The file should now contain encrypted text and the file was renamed.
        ![Anti-Ransomware](images/part5_step2b3.png)
        * Go back to system manager and view the snapshots for the share volume.  You should see a snapshot titled Anti_ransomware_backup. Select the Anti_ransomware_backup snapshot and restore it. Once it's restored you should see most of the files are back to their state before being encrypted.
        ![Anti-Ransomware](images/part5_step2b4.png)
