/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_print_memory.c                                  :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: xcarroll <xcarroll@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2022/02/22 16:17:55 by xcarroll          #+#    #+#             */
/*   Updated: 2022/02/24 00:30:39 by xcarroll         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <stdio.h>
#include <unistd.h>

void	ft_putchar(char c)
{
	write(1, &c, 1);
}

void	print_hex(int c)
{
	char	*hex;

	hex = "0123456789abcdef";
	if (c < 0)
	{
		c = 256 - c;
		ft_putchar(hex[c / 16]);
		ft_putchar(hex[c % 16]);
	}
	else
	{
		ft_putchar(hex[c / 16]);
		ft_putchar(hex[c % 16]);
	}
}

void	print_address(void *address)
{
	char	address_char[16];
	long	address_not_int_holy_fuck;
	int		i;

	address_not_int_holy_fuck = (long)address;
	i = 0;
	while (i < 15)
	{
		address_char[i] = address_not_int_holy_fuck % 16;
		if (address_char[i] > 9)
			address_char[i] += 87;
		else
			address_char[i] += '0';
		address_not_int_holy_fuck /= 16;
		i++;
	}
	i--;
	while (i > 0)
	{
		ft_putchar(address_char[i]);
		i--;
	}
	ft_putchar(address_char[i]);
	ft_putchar(':');
	ft_putchar(' ');
}

void	print_content(char *address, int size, int i)
{
	while (address[i] != '\0' && i < size)
	{
		print_hex(address[i]);
		if (i % 2 && i != size - 1)
			ft_putchar(' ');
		i++;
	}
	if (address[i] == '\0')
		print_hex(address[i]);
	while (i != size)
	{
		ft_putchar(' ');
		i++;
	}
	i = 0;
	while (address[i] != '\0' && i < size)
	{
		if (address[i] >= ' ' && address[i] <= '~')
			ft_putchar(address[i]);
		else
			ft_putchar('.');
		i++;
	}
	if (address[i] == '\0')
		ft_putchar('.');
}

void	*ft_print_memory(void *addr, unsigned int size)
{
	int		string_size;
	int		address_difference;
	char	*address;

	address = (char *)addr;
	string_size = 0;
	while (address[string_size] != '\0')
	{
		string_size++;
	}
	address_difference = 0;
	if (size != 0)
	{
		while (address_difference < string_size)
		{
			print_address(addr + address_difference);
			print_content(address + address_difference, 16, 0);
			ft_putchar('\n');
			address_difference += 16;
		}
	}
	return (addr);
}
