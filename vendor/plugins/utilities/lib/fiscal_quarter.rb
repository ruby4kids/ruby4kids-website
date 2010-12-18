require 'date'

class FiscalQuarter
	attr_accessor :actual_year, :actual_month, :fiscal_year, :fiscal_quarter, :start_month
	alias_method :quarter, :fiscal_quarter
	alias_method :year, :actual_year
	alias_method :month, :actual_month
	
	def initialize(date = Date.today)
    recalculate_from_actual_date(date.year, date.month)
	end
	
	def self.new_from_fiscal(year, quarter)
    fq = FiscalQuarter.new(Date.today)
    fq.recalculate_from_fiscal_quarter(year, quarter)
    return fq
  end
  
  def self.prev(n)
    return FiscalQuarter.new.prev(n)
  end
  
  def self.next(n)
    return FiscalQuarter.new.next(n)
  end
  
  def self.now
    return FiscalQuarter.new
  end
	
	# Optional format string parameters:
	# %q: the fiscal quarter
	# %y: the last two digits of the actual year
	# %Y: the actual year
	# %f: the last two digits of the fiscal year
	# %F: the fiscal year
	# %m: the month
	# %d: the last day of the month
	def to_s(format = "Q%q-%f")
	  if format == :db
	    return "#{@actual_year}-#{@actual_month}-01"
    end
    
		s = format

		[
			[/%q/, @fiscal_quarter.to_s],
			[/%y/, @actual_year.to_s[2, 2]],
			[/%Y/, @actual_year.to_s],
			[/%f/, @fiscal_year.to_s[2, 2]],
			[/%F/, @fiscal_year.to_s],
			[/%m/, @actual_month.to_s],
			[/%d/, calc_last_day_of_month(@actual_month, @actual_year).to_s]
		].each do |regex, str|
			s.gsub!(regex, str)
		end

		return s
	end
	
	def next(n = 1)
		x = self.clone
		n.times do 
			x.fiscal_quarter += 1
			if x.fiscal_quarter == 5
				x.fiscal_quarter = 1
				x.fiscal_year += 1
			end
			x.actual_month += 3
			if x.actual_month > 12
				x.actual_month -= 12
				x.actual_year += 1
			end
			x.start_month += 3
			if x.start_month > 12
				x.start_month -= 12
			end
		end
		return x
	end
	
	def prev(n = 1)
		x = self.clone
		n.times do
			x.fiscal_quarter -= 1
			if x.fiscal_quarter == 0
				x.fiscal_quarter = 4
				x.fiscal_year -= 1
			end
			x.actual_month -= 3
			if x.actual_month < 1
				x.actual_month += 12
				x.actual_year -= 1
			end
			x.start_month -= 3
			if x.start_month < 1
				x.start_month += 12
			end
		end
		return x
	end
	
	def start_date
    Date.new(@actual_year, @start_month, 1)
  end
  
  def end_date
    Date.new(@actual_year, @start_month + 2, calc_last_day_of_month(@start_month + 2, @actual_year))
  end
  
  def at_beginning_of_fiscal_year
    beg = self.clone
    beg.recalculate_from_fiscal_quarter(self.fiscal_year, 1)
    return beg
  end
	
	def calc_fiscal_months
	  cal_month=self.month
	  if (cal_month>=4) & (cal_month<=12)
	    cal_month=cal_month-3
	  else
	    cal_month=cal_month+9
    end 
    cal_month
	end
	
	def recalculate_from_fiscal_quarter(fiscal_year, fiscal_quarter)
	  @fiscal_year = fiscal_year.to_i
	  @fiscal_quarter = fiscal_quarter.to_i
	  
	  case @fiscal_quarter
    when 2
      @actual_year = @fiscal_year - 1
      @actual_month = 7
    when 3
      @actual_year = @fiscal_year - 1
      @actual_month = 10
    when 4
      @actual_year = @fiscal_year
      @actual_month = 1
    when 1
      @actual_year = @fiscal_year - 1
      @actual_month = 4
    else
      raise "Couldn't calculate fiscal quarter"
    end
    
    @start_month = @actual_month
  end
  
  def recalculate_from_actual_date(year, month)
    year, month = year.to_i, month.to_i
    @actual_year = year
    @actual_month = month
    
    case month
		when 7, 8, 9
			@fiscal_year = year + 1
			@fiscal_quarter = 2
			@start_month = 7
			
		when 10, 11, 12
			@fiscal_year = year + 1
			@fiscal_quarter = 3
			@start_month = 10
			
		when 1, 2, 3
			@fiscal_year = year
			@fiscal_quarter = 4
			@start_month = 1
			
		when 4, 5, 6
			@fiscal_year = year + 1
			@fiscal_quarter = 1
			@start_month = 4
			
		else
		  raise "Couldn't calculate fiscal quarter"
		end
  end
	
	def calc_last_day_of_month(month, year)
		case month
		when 1, 3, 5, 7, 8, 10, 12
			31
			
		when 4, 6, 9, 11
			30
			
		when 2
			if ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0)
				29
			else 
				28
			end
			
		else
		  raise "Couldn't calculate last day of the month"
		end
	end
	
	def fiscal_month
	  if @actual_month >= 4
	    return @actual_month - 3
	  else
	    return @actual_month + 9
    end 
  end; alias period fiscal_month
  
end

FQ = FiscalQuarter # alias

