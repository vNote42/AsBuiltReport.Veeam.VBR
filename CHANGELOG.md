# :arrows_clockwise: Veeam VBR As Built Report Changelog

## [0.4.2] - 2022-04-26

- Added detailed repository information of ScaleOut Backup Repository extents
     - Information of parent SOBR is also included

## [0.4.1] - 2022-04-24

### Added

- Added Backup Repository information about Immutability
  - Immutability Enabled: yes/no
  - Immutability Interval
- New Health Check about Immutability
  - If Repo supports Immutability and Immutability is disabled: Warning
- Added per section summary information
- Removed SQLServer module dependency
- Added VMware/HyperV job VM count


## [0.4.0] - 2022-02-27

### Added

- Added Backup Job Configuration information
  - VMware type Backup Jobs
    - VMware Backup Copy Jobs
  - Hyper-V Backup Jobs
    - Hyper-V Backup Copy Jobs
  - Tape Backup Job Configuration
    - Backup to Tape Jobs
    - File to Tape Jobs
  - SureBackup Job Configuration
    - VMware SureBackup Jobs
- Added Configuration Backup Section

### Changed

- Updated GitHub Action release workflow to send automated tweets on each release

## [0.3.1] - 2022-02-8

### Added

- Added option to set veeam custom tcp port (BackupServerPort)
- Added Volume Format to the BackupServer/Proxy section
- Added BackupServer/Proxy Network Interface Information
- Added process network Statistics ($InfoLevel.Infrastructure.BackupServer -ge 3)
- Added Storage Infrastructure section
  - Added NetApp Ontap support
  - Added Dell Isilon support
- Added initial Backup Job section
  - Added Tape Backup Job information
  - Added SureBackup Job information
  - Added Agent Backup Job information

### Changed

- Migrated Sample URL to htmlpreview.github.io

### Fixed

- Fixes Include Veeam Network Statistics in report #13
- Fixes Backup Server physical memory (GB) < 8 always returns true #14
- Fixes Add Veeam Backup\Repo Network Interface Information #15
- Fixes Add Backup Server\Repo Volume Format #16
- Fixes Add option to set veeam custom tcp port #17

## [0.3.0] - 2022-01-30

### Added

- Added File Share section.
- Added Veeam version information.
- Implemented table sorting on primary key.
- Added aditional backup server health checks
- Added Enterprise Manager Information
- Added Service Provider credential information

### Changed

- Improved table caption content.
- Changed ReadMe to include Supported Licenses Edtion.
- Added SQLServer module to manifest file

### Fixed

- Fix missing Infolevel sections.

## [0.2.0] - 2022-01-14

### Added

- Added if Condition to better validate License Edition.
- Added more try/case statements.
- Added Aditional Tape Infrastructure Sections.
  - Added Tape MediaPools Information.
  - Added NDMP Server Information.
- Added Initial Inventory Section Information.
  - Added Virtual Infrastructure Section.
    - Added VMware vSpere Section.
    - Added Microsoft Hyper-V Section.
  - Added Physical Infrastructure Section.
    - Added Protection Group Summary Section.
      - Added Protection Group Detailed Configuration.

### Changed

- Removed unneeded paragraph section.
- Changed ReadMe to include Supported Licenses Edtion.

### Fixed

- Fix many try/case statements

## [0.1.0] - 2022-01-05

### Added

- Added Backup Server Information.
  - Added Backup Server Hardware Inventory.
  - Added Backup Server Health Check.
    - Added Veaam services status check.
- Added License Information support.
  - Added Per Instance License Usage.
  - Added Per CPU Socket License Usage.
  - Added Capacity License Usage.
- Added General Option (Settings) Information.
  - Added support for Email Notification Settings
  - Added Storage Latency Control Options.
    - Added support for Per Datastore Latency Control Options.
  - Added support for Backup Server TLS Certificate Information.
  - Added Network Traffic Rules verification.
    - Added information of Preferred Networks settings.
- Added Security related Information.
  - Role and Users Information.
  - Credentils Information.
- Added Backup Proxy Infomation.
  - Added Health Check Support.
  - Added VMware Proxy Information.
  - Added Hyper-V Proxy Information.
- Added Wan Accelerator Information.
- Added Backup Repository Information.
  - Added Configuration Information.
  - Added ScaleOut Repository Information.
    - Added Performance Extent Information.
    - Added Capacity Extent Information.
  - Added Object Storage Support.
- Added SureBackup Information.
  - Added Application Group Information
    - Added per VM settings,
- Added Virtual Labs Information.
  - Added Configuration Information.
    - Added Per Virtual Lab Setting.
      - Added vNic Settings.
      - Added IP Address Mapping.
- Added Location Information
- Added Virtualization Servers and Hosts Information
- Added Tape Infrastructure Information.
  - Added Tape Server Information.
  - Added Tape Library Information.
    - Added Per Library Tape Drive Information.
  - Added Tape Vault Information.
- Added Veeam Logo to Cover Page.
