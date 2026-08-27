import yfinance as yf
import matplotlib.pyplot as plt

ticker = yf.Ticker("IDR=X")
df_kurs = ticker.history(start="2023-01-01", end="2026-07-31")
df_kurs = df_kurs.dropna(subset=['Close'])

#PLOT FORMATING
plt.figure(figsize=(10, 5))
plt.plot(df_kurs.index, df_kurs['Close'], color='blue', linewidth=1.5)

#LABELLING
plt.xlabel('Date', fontsize=12, fontweight='bold')
plt.ylabel('Exchange Rate (IDR per USD)', fontsize=12, fontweight='bold')

plt.grid(axis='y', linestyle='--', alpha=0.7)
plt.grid(axis='x', linestyle='--', alpha=0.5)

plt.tight_layout()
plt.show()

#--------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------
# quick notes:

# yf.Ticker('...') -> grabs the ticker data from yfinance
# plt.figure() -> creates the blank canvas/window

# plt.plot() -> plots the data. 
# use .index for the x-axis, .dropna() to drop NA rows, 
# and tweak color/linewidth for styling

# plt.title(), plt.xlabel(), plt.ylabel() -> labels & title
# (can pass fontsize, fontweight, pad for spacing)

# plt.grid() -> adds gridlines (use linestyle='--', alpha for opacity)
# plt.tight_layout() -> auto-fixes cut off labels/spacing
# plt.show() -> displays the plot
#--------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------
