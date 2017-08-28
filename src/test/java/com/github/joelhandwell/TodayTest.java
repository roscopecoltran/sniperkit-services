package com.github.joelhandwell;

import static org.junit.Assert.assertEquals;
import org.junit.Test;

import java.time.*;

public class TodayTest {
	@Test
	public void evaluateDate(){
		Today today = new Today();
		assertEquals(LocalDate.now().toString(), today.date());
	}
}
