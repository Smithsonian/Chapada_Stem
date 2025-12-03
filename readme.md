## Chapada-STEM Automated Greenhouse Gas Monitoring

| <img src="https://github.com/user-attachments/assets/7a92d132-21ee-4f01-8c2f-c62b2304565d" width="20000"> <br> <sub>The site of the Chapada Project</sub> |  The **Chapada-STEM** project is a collaborative research effort between the Cary Institute, Exeter University, and the Smithsonian Environmental Research Center (SERC). The project takes place in Brazil, within the *cerrado* biome—a tropical savanna ecosystem characterized by strong wet–dry seasonality, rich biodiversity, and a significant role in global carbon cycling.<br><br>SERC is responsible for the design, operation, and oversight of the automated chamber measurement system. Our goal is to generate continuous, automated measurements of ecosystem methane (CH₄) and carbon dioxide (CO₂) fluxes using the LI-COR 7810 gas analyzer. The project focuses on cerrado grasslands widely distributed throughout wetland areas, providing high-resolution insights into greenhouse gas exchange at the soil–atmosphere interface.|
|---|---|

---

## Project Overview

The Chapada-STEM automated chamber system is deployed along a soil moisture saturation gradient representative of cerrado landscapes, including:

- Permanently saturated wetlands  
- Seasonally saturated wetlands  
- Dry grasslands

To capture spatial variability in the cerrado wetland gas fluxes, the system includes:

- **8** chambers spanning the transition from permanently to seasonally saturated wetlands  
- **8** chambers spanning the transition from seasonally saturated wetlands to dry grasslands  
- **2** additional chambers installed on termite mounds

<p align="center">
  <img src="https://github.com/user-attachments/assets/9c639b34-be22-4c65-a82d-147c1a4ec13e" width="250">
  <img src="https://github.com/user-attachments/assets/51a7e231-b314-446f-b05d-be370d1c5480" width="250">
  <img src="https://github.com/user-attachments/assets/85469b48-e493-44fc-8a23-2c34a9c87c34" width="250">
    <br>
  <sub>Above are images of the chambers in the Chapada Project. There are 20 chambers total. Fluxes are measured when the lids on the chambers are closed.</sub>
</p>

<p align="center">
<img src="https://github.com/user-attachments/assets/2d2b7e72-1959-426d-bf48-52573ecafc75" width=75%>
<br>
<sub> A map showing the placement of the high and low areas of the site plus zoomed in maps of the chamber placement at each level. </sub>
</p>



Each site uses a solar-powered, continuously running system connected to an LI-COR 7810 gas analyzer. A programmable manifold system controls chamber lid opening and closing, sampling cycles, logging, and sensor power management. Data are sampled once per hour, providing consistent temporal coverage across all chambers.

<p align="center">
  <img src="https://github.com/user-attachments/assets/57fca6aa-e61e-41df-b10c-e4e42ef9e571" width="50%">
    <br>
  <sub>The Manifold acts as the "brain" of the project, controlling opening and closing of the chambers as well as logging the data from all sensors.</sub>
</p>

In addition to LICOR measurements, each chamber is outfitted with a [BME280](https://www.adafruit.com/product/2652?ref=dzombak.com&gad_source=1&gad_campaignid=21079267614&gbraid=0AAAAADx9JvRgjNv8OxXekStexoGHD-hAp&gclid=CjwKCAiA3L_JBhAlEiwAlcWO55uWiBtSrIyjafda2KTCu_CQeAkEK6QqgcySDoJhQi6N7LQPhTvmtBoC5boQAvD_BwE) sensor that takes air temperature, relative humidity, and barometric pressure measurements inside the chamber. In each plot, custom made redox probes and [Teros 12 Sensors](https://metergroup.com/products/teros-12/?srsltid=AfmBOorMv8T-iOJ6rGzm11_cGu7AcOZcUMA5f4RoiX4DimdKyG9t7joF) are deployed to measure redox potential and soil moisture in and around the chambers, respectively. 

A [ClimaVue50 Compact Ditigal Weather Monitoring System](https://www.campbellsci.com/climavue-50?gad_source=1&gad_campaignid=23283058683&gbraid=0AAAAAD9dhHqXpp5ofHZseLgZjYhIhUKEg&gclid=CjwKCAiA3L_JBhAlEiwAlcWO5495RiTmc4fwPRYT675hk4BZ01tsDGi26Dah-PNr2MDK2Wg_qHo8RBoCsbEQAvD_BwE) is deployed on site to collect weather related data. 

---

## Data Access and Visualization

All data are automatically uploaded to **LoggerNet**, enabling remote access for monitoring and quality control. Data from the chambers spanning permanently to seasonally saturated wetlands, as well as ClimaVue50 data, are logged on the "Chapada_Low" logger and data from the chambers spanning seasonally saturated wetlands to dry grasslands are logged on the "Chapada_High" Logger. Raw data from loggernet is funneled through the workflows above to create monthly CSV data files for the project. 

Additionally, LICOR data from all chambers are summarized daily on an interactive dashboard, which displays CH₄ and CO₂ fluxes for each chamber. This dashboard provides an at-a-glance view of system performance and environmental variability across the site. (More information aboutt he Dashboard will be added once the dashboard has been implemented) 
